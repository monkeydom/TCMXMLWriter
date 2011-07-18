//
//  UnitTests.m
//  UnitTests
//
//  Created by Dominik Wagner on 15.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "UnitTests.h"

@implementation UnitTests
@synthesize xmlWriter;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)remarshallXMLURL:(NSURL *)anURL {
	NSLog(@"%s %@", __FUNCTION__, anURL);
	TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionOrderedAttributes];
	self.xmlWriter = writer;
	[writer release];
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:anURL];
	parser.delegate = self;
	[parser parse];
	[parser release];
	
	
	self.xmlWriter = nil;
}

- (void)testRemarshalling {
	[self remarshallXMLURL:[[NSBundle bundleForClass:[UnitTests class]] URLForResource:@"fanboyspodcast.m4a" withExtension:@"rss"]];
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
//	NSLog(@"%s %@ %@",__FUNCTION__,elementName, attributeDict);
	[self.xmlWriter openTag:elementName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//	NSLog(@"%s %@",__FUNCTION__,elementName);
	[self.xmlWriter closeLastTag];
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data {
	NSLog(@"%s %@ %@",__FUNCTION__,target,data);	
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	NSString *cdataString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
	[self.xmlWriter cdata:cdataString];
	[cdataString release];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString {
	[self.xmlWriter text:aString];
}


- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)aString {
	[self.xmlWriter comment:aString];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	[self.xmlWriter instructXML];
}

- (void)parserDidEndDocument:(NSXMLParser *)parse {
	NSLog(@"%s result:\n\n%@", __FUNCTION__, self.xmlWriter.XMLString);
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
	// so ignore it
}

@end
