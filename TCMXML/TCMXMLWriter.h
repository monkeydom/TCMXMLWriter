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
	TCMXMLWriterOptionPrettyPrinted = 1UL << 0
};
typedef NSUInteger TCMXMLWriterOptions;

@interface TCMXMLWriter : NSObject {

}

@property (nonatomic,retain) NSURL *fileURL;

- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField; // stores marshalled stuff in string
- (id)initWithOptions:(TCMXMLWriterOptions)anOptionField fileURL:(NSURL *)aFileURL;


- (void)instruct:(NSString *)anInstructionName attributes:(NSDictionary *)anAttributeDictionary;

//- (void)tag:(NSString *)aTagName;
//- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary;
//- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentXML:(NSString *)aContentXML;
//- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentText:(NSString *)aContentText;
- (void)tag:(NSString *)aTagName attributes:(NSDictionary *)anAttributeDictionary contentBlock:(void (^)(void))aContentBlock;
- (void)text:(NSString *)aTextString;
- (NSString *)XMLString; // returns the result as string


@end
