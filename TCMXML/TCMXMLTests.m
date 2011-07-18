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
	[writer instruct:@"xml" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"1.0",@"version",@"UTF-8",@"encoding", nil]];
	[writer tag:@"loanDatabase" attributes:nil contentBlock:^{
		[writer tag:@"loans" attributes:nil contentBlock:^{
			[writer tag:@"loan" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"loan-123124",@"id",@"item-1231",@"itemID",@"friend-111",@"friendID", nil] contentBlock:^{
				[writer text:@"This item has some content text!"];
			}];
			[writer tag:@"loan" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"loan-123125",@"id",@"item-1231",@"itemID",@"friend-111",@"friendID", nil] contentText:@"This item has some direct content text!"];
			for (int i=0; i<10; i++) {
				[writer tag:@"loan" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Loan/p%d",i],@"id",[NSDate date],@"dueDate",[NSNumber numberWithInt:i],@"someNumber",[NSNumber numberWithFloat:(float)i/7.0],@"someFloat", nil]];
			}
		}];
		[writer tag:@"items" attributes:nil contentBlock:^{
			[writer tag:@"item" attributes:nil contentBlock:^{
				[writer tag:@"ImageData" attributes:nil contentCDATA:@"This is quite literally a end]]> cdata ]]> problem"];
			}];
		}];
		[writer comment:@"Some comment about \"friends\" -- you know -"];
		[writer tag:@"friends" attributes:nil contentBlock:^{
			
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
	[writer tag:@"img" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"http://blah.to/foo&bar=\"foo\"",@"href", nil]];
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
	[writer instruct:@"xml" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"1.0",@"version",@"UTF-8",@"encoding", nil]];
	STAssertEqualObjects(writer.XMLString,@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" , @"Instruct failed");
	[writer release];
}

@end
