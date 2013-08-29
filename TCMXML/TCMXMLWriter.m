//
//  TCMXMLWriter.m
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

// this file needs arc - either project wide,
// or add -fobjc-arc on a per file basis in the compile build phase
// for a pre arc version go to https://github.com/monkeydom/TCMXMLWriter/tree/295a377f60104afe6d13124cbe6105aaff5c1317
#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

#import "TCMXMLWriter.h"

#define SHOULDPRETTYPRINT (_writerOptions & TCMXMLWriterOptionPrettyPrinted)
#define SHOULDPRETTYBOOL  (_writerOptions & TCMXMLWriterOptionPrettyBOOL)

@interface TCMXMLWriter ()
@property BOOL currentTagHasContent;
@property (nonatomic, strong) NSMutableString *indentationString;
@property TCMXMLWriterOptions writerOptions;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableArray *elementNameStackArray;
- (void)writeAttributes:(NSDictionary *)anAttributeDictionary;
- (void)writeString:(NSString *)aString;
- (void)createAndOpenStream;
@end

@implementation TCMXMLWriter

@synthesize writerOptions = _writerOptions;
@synthesize outputStream  = _outputStream;
@synthesize elementNameStackArray = _elementNameStackArray;
@synthesize indentationString = _indentationString;
@synthesize currentTagHasContent = _currentTagHasContent;
@synthesize dateFormatter = _dateFormatter;

@synthesize fileURL = _fileURL;

- (id)init {
    return [self initWithOptions:0];
}

- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField {
	if ((self = [super init])) {
		_elementNameStackArray = [NSMutableArray new];
		self.writerOptions = anOptionField;
		_indentationString = [NSMutableString new];
		_dateFormatter = [NSDateFormatter new];
		_boolNOValue = @"no";
		_boolYESValue = @"yes";
		[_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	}
	return self;
}
- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField fileURL:(NSURL *)aFileURL {
	if ((self = [self initWithOptions:anOptionField])) {
		self.fileURL = aFileURL;
	}
	return self;
}

- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField outputStream:(NSOutputStream *)anOutputStream {
	if ((self = [self initWithOptions:anOptionField])) {
		self.outputStream = anOutputStream;
	}
	return self;
}

- (void)dealloc {
	if (self.fileURL) [self.outputStream close];
}



- (void)createAndOpenStream {
	if (self.fileURL) {
		if (![[NSFileManager defaultManager] isWritableFileAtPath:[self.fileURL path]]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:[[self.fileURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
		}
		self.outputStream = [NSOutputStream outputStreamWithURL:self.fileURL append:NO];
	} else {
		self.outputStream = [NSOutputStream outputStreamToMemory]; 
	}
	[self.outputStream open];
}

- (void)writeString:(NSString *)aString {
	if (aString.length > 0) {
		if (!self.outputStream) [self createAndOpenStream];
		// TODO: needs to handle output stream capacity problems, so probably one idirection is still in order.
		CFDataRef dataRef = CFStringCreateExternalRepresentation(NULL, (CFStringRef)aString, kCFStringEncodingUTF8, 0);
		if (dataRef) {
			UInt8 *bytes = (UInt8 *)CFDataGetBytePtr(dataRef);
			UInt8 *endOfBytes = bytes + CFDataGetLength(dataRef);
			do {
				NSInteger writtenLength = [_outputStream write:bytes maxLength:endOfBytes-bytes];
				if (writtenLength == -1 || writtenLength == 0) {
					NSLog(@"stream error occured: %@", [_outputStream streamError]);
					break;
				}
				bytes += writtenLength;
			} while (bytes != endOfBytes);
			CFRelease(dataRef);
		}
	}
}

- (void)writeAttributeValueEscaped:(id)anAttributeValue {
	BOOL needsEscaping = YES;
	NSMutableString *escapedString = nil;
	NSString *string = nil;
	if ([anAttributeValue isKindOfClass:[NSString class]]) {
		escapedString = [anAttributeValue mutableCopy];
	} else if ([anAttributeValue isKindOfClass:[NSDate class]]) {
		needsEscaping = NO;
		string = [_dateFormatter stringFromDate:anAttributeValue];
	} else if ([anAttributeValue isKindOfClass:[NSNumber class]]) {
		NSNumber *value = (NSNumber *)anAttributeValue;
		needsEscaping = NO;
		if (value == (NSNumber *)kCFBooleanTrue && SHOULDPRETTYBOOL) {
			string = _boolYESValue;
		} else if (value == (NSNumber *)kCFBooleanFalse && SHOULDPRETTYBOOL) {
			string = _boolNOValue;
		} else {
			string = [value stringValue];
		}
	}
	if (needsEscaping) {
		[escapedString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
		[escapedString replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
		[escapedString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
		[self writeString:escapedString];
	} else {
		[self writeString:string];
	}
		
}

- (void)writeStringXMLEscaped:(NSString *)aString {
	// see http://www.w3.org/TR/xml11/
	NSMutableString *escapedString = [aString mutableCopy];
	[escapedString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[escapedString replaceOccurrencesOfString:@"<" withString:@"&lt;"  options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[escapedString replaceOccurrencesOfString:@"]]>" withString:@"]]&gt;"  options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[self writeString:escapedString];
}

- (void)writeAttributes:(NSDictionary *)anAttributeDictionary {
	void (^writerBlock)(id key, id obj, BOOL *stop)  = ^(id key,id value,BOOL *stop){
		[self writeString:@" "];
		[self writeString:key];
		[self writeString:@"="];
		[self writeString:@"\""];
		[self writeAttributeValueEscaped:value];
		[self writeString:@"\""];
	};
	if (_writerOptions & TCMXMLWriterOptionOrderedAttributes) {
		NSMutableArray *sortedAttributeKeys = [[anAttributeDictionary allKeys] mutableCopy];
		[sortedAttributeKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
		for (NSString *key in sortedAttributeKeys) {
			writerBlock(key, anAttributeDictionary[key], NULL);
		}
	} else {
		[anAttributeDictionary enumerateKeysAndObjectsUsingBlock:writerBlock];
	}
}

- (void)instructXML {
	[self instruct:@"xml" attributes:@{@"version": @"1.0",@"encoding": @"UTF-8"}];
}

- (void)instructXMLStandalone {
	[self instruct:@"xml" attributes:@{@"version": @"1.0",@"encoding": @"UTF-8",@"standalone": @"yes"}];
}

- (void)instruct:(NSString *)anInstructionName attributes:(NSDictionary *)anAttributeDictionary {
	[self writeString:@"<?"];
	[self writeString:anInstructionName];
	if (anAttributeDictionary[@"version"]) {
		// special case - version needs to be first
		NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
		tempDictionary[@"version"] = anAttributeDictionary[@"version"];
		[self writeAttributes:tempDictionary];
		[tempDictionary addEntriesFromDictionary:anAttributeDictionary];
		[tempDictionary removeObjectForKey:@"version"];
		[self writeAttributes:tempDictionary];		
	} else {
		[self writeAttributes:anAttributeDictionary];
	}
	[self writeString:@"?>"];
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}


- (void)openTag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary hasDirectContent:(BOOL)hasDirectContent {
	if (SHOULDPRETTYPRINT) {
		[self writeString:_indentationString];
	}
	[self writeString:@"<"];
	[self writeString:aTagName];
	[self writeAttributes:anAttributeDictionary];
	[self writeString:@">"];	
	[self.elementNameStackArray addObject:aTagName];
	if (SHOULDPRETTYPRINT) {
		if (!hasDirectContent) [self writeString:@"\n"];
	}
	[_indentationString appendString:@"\t"];
	_currentTagHasContent = NO;
}

- (void)openTag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary {
	[self openTag:aTagName attributes:anAttributeDictionary hasDirectContent:NO];
}

- (void)openTag:(NSString *)aTagName {
	[self openTag:aTagName attributes:nil];
}


- (void)closeLastTag {
	NSString *tagName = [self.elementNameStackArray lastObject];
	[_indentationString deleteCharactersInRange:NSMakeRange(_indentationString.length-1,1)];
	if (SHOULDPRETTYPRINT) {
		[self writeString:_indentationString];
	}
	[self writeString:@"</"];
	[self writeString:tagName];
	[self writeString:@">"];
	[self.elementNameStackArray removeLastObject];
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentBlock:(void (^)(void))aContentBlock {
	[self openTag:aTagName attributes:anAttributeDictionary];
	aContentBlock();
	[self closeLastTag];
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentXML:(NSString *)aContentXML {
	[self openTag:aTagName attributes:anAttributeDictionary];
	[self xml:aContentXML];
	[self closeLastTag];
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentText:(NSString *)aContentText {
	[self openTag:aTagName attributes:anAttributeDictionary hasDirectContent:YES];
	NSUInteger oldOptions = _writerOptions;
	_writerOptions = oldOptions & (~TCMXMLWriterOptionPrettyPrinted);
	[self text:aContentText];
	[self closeLastTag];
	_writerOptions = oldOptions;
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentCDATA:(NSString *)aContentCDATA {
	[self openTag:aTagName attributes:anAttributeDictionary hasDirectContent:YES];
	NSUInteger oldOptions = _writerOptions;
	_writerOptions = oldOptions & (~TCMXMLWriterOptionPrettyPrinted);
	[self cdata:aContentCDATA];
	[self closeLastTag];
	_writerOptions = oldOptions;
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

// shortcuts
- (void)tag:(NSString *)aTagName contentBlock:(void (^)(void))aContentBlock {
	[self tag:aTagName attributes:nil contentBlock:aContentBlock];
}
- (void)tag:(NSString *)aTagName contentXML:(NSString *)aContentXML {
	[self tag:aTagName attributes:nil contentXML:aContentXML];
}
- (void)tag:(NSString *)aTagName contentText:(NSString *)aContentText {
	[self tag:aTagName attributes:nil contentText:aContentText];
}
- (void)tag:(NSString *)aTagName contentCDATA:(NSString *)aContentCDATA {
	[self tag:aTagName attributes:nil contentCDATA:aContentCDATA];
}



- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary {
	if (SHOULDPRETTYPRINT) {
		[self writeString:_indentationString];
	}
	[self writeString:@"<"];
	[self writeString:aTagName];
	[self writeAttributes:anAttributeDictionary];
	[self writeString:@"/>"];
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)comment:(NSString *)aCommentContent {
	if (SHOULDPRETTYPRINT) {
		[self writeString:_indentationString];
	}	
	[self writeString:@"<!-- "];
	[self writeString:aCommentContent];
	[self writeString:@" -->"];	
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}


- (void)text:(NSString *)aTextString {
	if (SHOULDPRETTYPRINT) {
		[self writeString:_indentationString];
	}	
	[self writeStringXMLEscaped:aTextString];
	_currentTagHasContent = YES;
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)xml:(NSString *)anXMLSnippet {
	[self writeString:anXMLSnippet];
	_currentTagHasContent = YES;
}

- (void)cdata:(NSString *)aCDataString {
	if (SHOULDPRETTYPRINT) {
		[self writeString:_indentationString];
	}	
	[self writeString:@"<![CDATA["];
	
	if ([aCDataString rangeOfString:@"]]>"].location != NSNotFound) {
		NSMutableString *escapedString = [aCDataString mutableCopy];
		[escapedString replaceOccurrencesOfString:@"]]>" withString:@"]]" @"]]><![CDATA[" @">" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
		[self writeString:escapedString];
	} else {
		[self writeString:aCDataString];
	}
	
	[self writeString:@"]]>"];
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
	_currentTagHasContent = YES;
}

- (NSData *)XMLData {
	NSData *result = nil;
	if (self.fileURL) {
		result = [NSData dataWithContentsOfURL:self.fileURL options:0 error:NULL];
	} else {
		result = [_outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	}
	return result;
}

- (NSString *)XMLString {
	NSData *outputData = self.XMLData;
	return [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
}

@end
