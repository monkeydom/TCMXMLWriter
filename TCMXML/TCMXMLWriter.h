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
	TCMXMLWriterOptionOrderedAttributes = 1UL << 1, // mainly for unit testing to get reproducible results, but can also be helpful otherwise for stable results
	TCMXMLWriterOptionPrettyBOOL = 1UL << 2 // prints BOOLEAN NSNumbers as boolYESValue and boolNOValue values - default is "yes" and "no" 
};
typedef NSUInteger TCMXMLWriterOptions;

@interface TCMXMLWriter : NSObject {}

@property (nonatomic,strong) NSURL *fileURL;
@property (unsafe_unretained, readonly) NSString *XMLString; // works for in memory streams and file URLs
@property (unsafe_unretained, readonly) NSData *XMLData; // works for in memory streams and file URLs
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *boolYESValue;
@property (nonatomic, strong) NSString *boolNOValue;

- (instancetype)initWithOptions:(TCMXMLWriterOptions)anOptionField; // stores marshalled stuff in string
- (instancetype)initWithOptions:(TCMXMLWriterOptions)anOptionField fileURL:(NSURL *)aFileURL;
// stream must be open
- (instancetype)initWithOptions:(TCMXMLWriterOptions)anOptionField outputStream:(NSOutputStream *)anOutputStream;

// meta
- (void)instructXMLStandalone; // <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
- (void)instructXML; // <?xml version="1.0" encoding="UTF-8"?>
- (void)instruct:(NSString *)anInstructionName attributes:(NSDictionary *)anAttributeDictionary;
- (void)comment:(NSString *)aCommentContent;

// asynchronous tags
- (void)openTag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary;
- (void)openTag:(NSString *)aTagName; // attributeless
- (void)closeLastTag;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary; // contentless

// synchronous tags
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentBlock:(void (^)(void))aContentBlock;

// direct data tags (for prettier formatting)
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentXML:(NSString *)aContentXML;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentText:(NSString *)aContentText;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentCDATA:(NSString *)aContentCDATA;

// shortcuts for attributeless tags
- (void)tag:(NSString *)aTagName contentBlock:(void (^)(void))aContentBlock;
- (void)tag:(NSString *)aTagName contentXML:(NSString *)aContentXML;
- (void)tag:(NSString *)aTagName contentText:(NSString *)aContentText;
- (void)tag:(NSString *)aTagName contentCDATA:(NSString *)aContentCDATA;


// content
- (void)text:(NSString *)aTextString;
- (void)cdata:(NSString *)aCDataString;
- (void)xml:(NSString *)anXMLSnippet;

@end
