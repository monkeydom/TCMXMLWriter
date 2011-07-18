//
//  TCMXMLWriter.m
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "TCMXMLWriter.h"

#define SHOULDPRETTYPRINT (I_writerOptions & TCMXMLWriterOptionPrettyPrinted)

@interface TCMXMLWriter ()
@property BOOL currentTagHasContent;
@property NSMutableString *indentationString;
@property TCMXMLWriterOptions writerOptions;
@property (retain) NSOutputStream *outputStream;
@property (retain) NSMutableArray *elementNameStackArray;
- (void)writeAttributes:(NSDictionary *)anAttributeDictionary;
- (void)writeString:(NSString *)aString;
- (void)createAndOpenStream;
@end

@implementation TCMXMLWriter

@synthesize writerOptions = I_writerOptions;
@synthesize outputStream  = I_outputStream;
@synthesize elementNameStackArray = I_elementNameStackArray;
@synthesize indentationString = I_indentationString;
@synthesize currentTagHasContent = I_currentTagHasContent;

@synthesize fileURL = I_fileURL;

- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField {
	if ((self = [super init])) {
		I_elementNameStackArray = [NSMutableArray new];
		self.writerOptions = anOptionField;
		I_indentationString = [NSMutableString new];
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
	self.outputStream = nil;
	self.fileURL = nil;
	self.elementNameStackArray = nil;
	self.indentationString = nil;
	[super dealloc];
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
				NSInteger writtenLength = [I_outputStream write:bytes maxLength:endOfBytes-bytes];
				if (writtenLength == -1 || writtenLength == 0) {
					NSLog(@"stream error occured: %@", [I_outputStream streamError]);
					break;
				}
				bytes += writtenLength;
			} while (bytes != endOfBytes);
			CFRelease(dataRef);
		}
	}
}

- (void)writeAttributeValueEscaped:(id)aAttributeValue {
	// TODO: handle other data types as well
	NSMutableString *escapedString = [aAttributeValue mutableCopy];
	[escapedString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[escapedString replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[self writeString:escapedString];
	[escapedString release];
	
}

- (void)writeStringXMLEscaped:(NSString *)aString {
	// see http://www.w3.org/TR/xml11/
	NSMutableString *escapedString = [aString mutableCopy];
	[escapedString replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[escapedString replaceOccurrencesOfString:@"<" withString:@"&lt;"  options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[escapedString replaceOccurrencesOfString:@"]]>" withString:@"]]&gt;"  options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
	[self writeString:escapedString];
	[escapedString release];
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
	if (I_writerOptions & TCMXMLWriterOptionOrderedAttributes) {
		NSMutableArray *sortedAttributeKeys = [[anAttributeDictionary allKeys] mutableCopy];
		[sortedAttributeKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
		for (NSString *key in sortedAttributeKeys) {
			writerBlock(key, [anAttributeDictionary objectForKey:key], NULL);
		}
		[sortedAttributeKeys release];
	} else {
		[anAttributeDictionary enumerateKeysAndObjectsUsingBlock:writerBlock];
	}
}

- (void)instructXML {
	[self instruct:@"xml" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"1.0",@"version",@"UTF-8",@"encoding", nil]];
}

- (void)instructXMLStandalone {
	[self instruct:@"xml" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"1.0",@"version",@"UTF-8",@"encoding",@"yes",@"standalone", nil]];
}

- (void)instruct:(NSString *)anInstructionName attributes:(NSDictionary *)anAttributeDictionary {
	[self writeString:@"<?"];
	[self writeString:anInstructionName];
	if ([anAttributeDictionary objectForKey:@"version"]) {
		// special case - version needs to be first
		NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
		[tempDictionary setObject:[anAttributeDictionary objectForKey:@"version"] forKey:@"version"];
		[self writeAttributes:tempDictionary];
		[tempDictionary addEntriesFromDictionary:anAttributeDictionary];
		[tempDictionary removeObjectForKey:@"version"];
		[self writeAttributes:tempDictionary];		
		[tempDictionary release];
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
		[self writeString:I_indentationString];
	}
	[self writeString:@"<"];
	[self writeString:aTagName];
	[self writeAttributes:anAttributeDictionary];
	[self writeString:@">"];	
	[self.elementNameStackArray addObject:aTagName];
	if (SHOULDPRETTYPRINT) {
		if (!hasDirectContent) [self writeString:@"\n"];
	}
	[I_indentationString appendString:@"\t"];
	I_currentTagHasContent = NO;
}

- (void)openTag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary {
	[self openTag:aTagName attributes:anAttributeDictionary hasDirectContent:NO];
}

- (void)closeLastTag {
	NSString *tagName = [self.elementNameStackArray lastObject];
	[I_indentationString deleteCharactersInRange:NSMakeRange(I_indentationString.length-1,1)];
	if (SHOULDPRETTYPRINT) {
		[self writeString:I_indentationString];
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
	NSUInteger oldOptions = I_writerOptions;
	I_writerOptions = oldOptions & (~TCMXMLWriterOptionPrettyPrinted);
	[self text:aContentText];
	[self closeLastTag];
	I_writerOptions = oldOptions;
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentCDATA:(NSString *)aContentCDATA {
	[self openTag:aTagName attributes:anAttributeDictionary hasDirectContent:YES];
	NSUInteger oldOptions = I_writerOptions;
	I_writerOptions = oldOptions & (~TCMXMLWriterOptionPrettyPrinted);
	[self cdata:aContentCDATA];
	[self closeLastTag];
	I_writerOptions = oldOptions;
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary {
	if (SHOULDPRETTYPRINT) {
		[self writeString:I_indentationString];
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
		[self writeString:I_indentationString];
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
		[self writeString:I_indentationString];
	}	
	[self writeStringXMLEscaped:aTextString];
	I_currentTagHasContent = YES;
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
}

- (void)xml:(NSString *)anXMLSnippet {
	[self writeString:anXMLSnippet];
	I_currentTagHasContent = YES;
}

- (void)cdata:(NSString *)aCDataString {
	if (SHOULDPRETTYPRINT) {
		[self writeString:I_indentationString];
	}	
	[self writeString:@"<![CDATA["];
	
	if ([aCDataString rangeOfString:@"]]>"].location != NSNotFound) {
		NSMutableString *escapedString = [aCDataString mutableCopy];
		[escapedString replaceOccurrencesOfString:@"]]>" withString:@"]]" @"]]><![CDATA[" @">" options:NSLiteralSearch range:NSMakeRange(0,escapedString.length)];
		[self writeString:escapedString];
		[escapedString release];
	} else {
		[self writeString:aCDataString];
	}
	
	[self writeString:@"]]>"];
	if (SHOULDPRETTYPRINT) {
		[self writeString:@"\n"];
	}
	I_currentTagHasContent = YES;
}

- (NSString *)XMLString {
	NSData *outputData = nil;
	if (self.fileURL) {
		outputData = [NSData dataWithContentsOfURL:self.fileURL];
	} else {
		outputData = [I_outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	}
	return [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
}

@end
