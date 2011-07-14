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

@synthesize writerOptions;
@synthesize outputStream;

@synthesize fileURL;

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
	CFDataRef dataRef = CFStringCreateExternalRepresentation(NULL, (CFStringRef)aString, kCFStringEncodingUTF8, 0);
	if (dataRef) {
		UInt8 *bytes = (UInt8 *)CFDataGetBytePtr(dataRef);
		UInt8 *endOfBytes = bytes + CFDataGetLength(dataRef);
		do {
			NSInteger writtenLength = [outputStream write:bytes maxLength:endOfBytes-bytes];
			if (writtenLength == -1 || writtenLength == 0) {
				NSLog(@"stream error occured: %@", [outputStream streamError]);
				break;
			}
			bytes += writtenLength;
		} while (bytes != endOfBytes);
		CFRelease(dataRef);
	}
}

- (void)writeAttributes:(NSDictionary *)anAttributeDictionary {
	[anAttributeDictionary enumerateKeysAndObjectsUsingBlock:^(id key,id value,BOOL *stop){
		[self writeString:@" "];
		[self writeString:key];
		[self writeString:@"="];
		[self writeString:@"\""];
		[self writeString:value];
		[self writeString:@"\""];
	}];
}

- (void)instruct:(NSString *)anInstructionName attributes:(NSDictionary *)anAttributeDictionary {
	[self writeString:@"<?"];
	[self writeString:anInstructionName];
	[self writeAttributes:anAttributeDictionary];
	[self writeString:@" ?>"];
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

- (void)text:(NSString *)aTextString {
	[self writeString:aTextString];
}


- (void)dealloc {
	[self.outputStream close];
	[self.outputStream release];
	self.fileURL = nil;
	[super dealloc];
}

- (NSString *)XMLString {
	NSData *outputData = nil;
	if (self.fileURL) {
		outputData = [NSData dataWithContentsOfURL:self.fileURL];
	} else {
		outputData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
	}
	return [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
}

@end
