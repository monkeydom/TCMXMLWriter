//
//  TCMXMLWriter.m
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "TCMXMLWriter.h"


@interface TCMXMLWriter ()
@property TCMXMLWriterOptions writerOptions;
@property (retain) NSOutputStream *outputStream;
- (void)writeAttributes:(NSDictionary *)anAttributeDictionary;
- (void)writeString:(NSString *)aString;
- (void)createAndOpenStream;
@end

@implementation TCMXMLWriter

@synthesize writerOptions = I_writerOptions;
@synthesize outputStream  = I_outputStream;

@synthesize fileURL = I_fileURL;

- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField {
	if ((self = [super init])) {
		self.writerOptions = anOptionField;
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

- (void)createAndOpenStream {
	if (self.fileURL) {
		self.outputStream = [NSOutputStream outputStreamWithURL:self.fileURL append:NO];
	} else {
		self.outputStream = [NSOutputStream outputStreamToMemory]; 
	}
	[self.outputStream open];
}

- (void)writeString:(NSString *)aString {
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
	[anAttributeDictionary enumerateKeysAndObjectsUsingBlock:^(id key,id value,BOOL *stop){
		[self writeString:@" "];
		[self writeString:key];
		[self writeString:@"="];
		[self writeString:@"\""];
		[self writeAttributeValueEscaped:value];
		[self writeString:@"\""];
	}];
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
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentBlock:(void (^)(void))aContentBlock {
	[self writeString:@"<"];
	[self writeString:aTagName];
	[self writeAttributes:anAttributeDictionary];
	[self writeString:@">"];	
		aContentBlock();
	[self writeString:@"</"];
	[self writeString:aTagName];
	[self writeString:@">"];	
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentXML:(NSString *)aContentXML {
	[self tag:aTagName attributes:anAttributeDictionary contentBlock:^{[self xml:aContentXML];}];
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentText:(NSString *)aContentText {
	[self tag:aTagName attributes:anAttributeDictionary contentBlock:^{[self text:aContentText];}];
}

- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary {
	[self writeString:@"<"];
	[self writeString:aTagName];
	[self writeAttributes:anAttributeDictionary];
	[self writeString:@"/>"];	
}

- (void)comment:(NSString *)aCommentContent {
	[self writeString:@"<!-- "];
	[self writeString:aCommentContent];
	[self writeString:@" -->"];	
}


- (void)text:(NSString *)aTextString {
	[self writeStringXMLEscaped:aTextString];
}

- (void)xml:(NSString *)anXMLSnippet {
	[self writeString:anXMLSnippet];
}

- (void)cdata:(NSString *)aCDataString {
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
}

- (void)dealloc {
	if (self.fileURL) [self.outputStream close];
	self.outputStream = nil;
	self.fileURL = nil;
	[super dealloc];
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
