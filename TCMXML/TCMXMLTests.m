//
//  TCMXMLTests.m
//  TCMinem
//
//  Created by Dominik Wagner on 15.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "TCMXMLTests.h"
#import "TCMXMLWriter.h"

@implementation TCMXMLTests

// All code under test must be linked into the Unit Test bundle
- (void)testInMemory {
	
	TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionOrderedAttributes | TCMXMLWriterOptionPrettyPrinted];
	[writer instruct:@"xml" attributes:@{@"version": @"1.0",@"encoding": @"UTF-8"}];
	[writer tag:@"loanDatabase" contentBlock:^{
		[writer tag:@"loans" contentBlock:^{
			[writer tag:@"loan" attributes:@{@"id": @"loan-123124",@"itemID": @"item-1231",@"friendID": @"friend-111"} contentBlock:^{
				[writer text:@"This item has some content text!"];
			}];
			[writer tag:@"loan" attributes:@{@"id": @"loan-123125",@"itemID": @"item-1231",@"friendID": @"friend-111",@"no": @NO,@"yes": @YES} contentText:@"This item has some direct content text!"];
			for (int i=0; i<10; i++) {
				[writer tag:@"loan" attributes:@{@"id": [NSString stringWithFormat:@"Loan/p%d",i],@"dueDate": [NSDate date],@"someNumber": @(i),@"someFloat": [NSNumber numberWithFloat:(float)i/7.0]}];
			}
		}];
		[writer tag:@"items" contentBlock:^{
			[writer tag:@"item" contentBlock:^{
				[writer tag:@"ImageData" contentCDATA:@"This is quite literally a end]]> cdata ]]> problem"];
			}];
		}];
		[writer comment:@"Some comment about \"friends\" -- you know -"];
		[writer tag:@"friends" contentBlock:^{
			
		}];
	}];
	NSLog(@"result XML: \n%@", writer.XMLString);
	[writer release];
}

- (void)testXMLEscaping {
	TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:0];
	[writer text:@"abc&de<fghi"];
	STAssertEqualObjects(writer.XMLString,@"abc&amp;de&lt;fghi" , @"Basics haven't been escaped right");
	[writer release];
}

- (void)testAttributeEscaping {
	TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:0];
	[writer tag:@"img" attributes:@{@"href": @"http://blah.to/foo&bar=\"foo\""}];
	STAssertEqualObjects(writer.XMLString,@"<img href=\"http://blah.to/foo&amp;bar=&quot;foo&quot;\"/>" , @"Attributes haven't been escaped right");
	[writer release];
}

- (void)testCDATAEscaping {
	TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:0];
	[writer cdata:@"Premature ]]> End?"];
	STAssertEqualObjects(writer.XMLString,@"<![CDATA[Premature ]]]]><![CDATA[> End?]]>" , @"Attributes haven't been escaped right");
	[writer release];
}

- (void)testInstruct {
	TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:0];
	[writer instruct:@"xml" attributes:@{@"version": @"1.0",@"encoding": @"UTF-8"}];
	STAssertEqualObjects(writer.XMLString,@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" , @"Instruct failed");
	[writer release];
}

@end
