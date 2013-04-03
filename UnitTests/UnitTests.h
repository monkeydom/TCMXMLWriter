//
//  UnitTests.h
//  UnitTests
//
//  Created by Dominik Wagner on 15.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TCMXMLWriter.h"

@interface UnitTests : SenTestCase <NSXMLParserDelegate> {
	
}

@property (strong) TCMXMLWriter *xmlWriter;

- (void)remarshallXMLURL:(NSURL *)anURL;


@end
