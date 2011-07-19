//
//  TCMXMLWriter.h
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TCMWriterOptionNoOptions = 0UL;

enum {
	TCMXMLWriterOptionPrettyPrinted = 1UL << 0,
	TCMXMLWriterOptionOrderedAttributes = 1UL << 1 // mainly for unit testing to get reproducible results, but can also be helpful otherwise for stable results
};
typedef NSUInteger TCMXMLWriterOptions;

@interface TCMXMLWriter : NSObject {}

@property (nonatomic,retain) NSURL *fileURL;
@property (readonly) NSString *XMLString; // works for in memory streams and file URLs
@property (readonly) NSData *XMLData; // works for in memory streams and file URLs
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField; // stores marshalled stuff in string
- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField fileURL:(NSURL *)aFileURL;
// stream must be open
- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField outputStream:(NSOutputStream *)anOutputStream;

// meta
- (void)instructXMLStandalone; // <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
- (void)instructXML; // <?xml version="1.0" encoding="UTF-8"?>
- (void)instruct:(NSString *)anInstructionName attributes:(NSDictionary *)anAttributeDictionary;
- (void)comment:(NSString *)aCommentContent;

// asynchronous tags
- (void)openTag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary;
- (void)closeLastTag;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary; // contentless

// synchronous tags
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentBlock:(void (^)(void))aContentBlock;

// direct data tags (for prettier formatting)
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentXML:(NSString *)aContentXML;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentText:(NSString *)aContentText;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentCDATA:(NSString *)aContentCDATA;

// content
- (void)text:(NSString *)aTextString;
- (void)cdata:(NSString *)aCDataString;
- (void)xml:(NSString *)anXMLSnippet;

@end
