//
//  RootViewController.m
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "RootViewController.h"
#import "TCMXMLWriter.h"

static NSString * const kTitleKey = @"title";
static NSString * const kBlockKey = @"block";

@interface RootViewController ()
- (void)setupContent;
- (void)addBlock:(void (^)(void))aBlock withTitle:(NSString *)aTitle;
- (void (^)(void))blockAtIndex:(NSUInteger)anIndex;
- (NSString *)titleAtIndex:(NSUInteger)anIndex;
- (NSURL *)tempFileURL;
@end

@implementation RootViewController

- (void)sharedInit {
	contentArray = [NSMutableArray new];
	[self setupContent];
}

- (id)initWithStyle:(UITableViewStyle)aStyle {
	if ((self=[super initWithStyle:aStyle])) {
		[self sharedInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self=[super initWithCoder:aDecoder])) {
		[self sharedInit];
	}
	return self;
}

- (void)setupContent {
	[self addBlock:^{
		TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionPrettyPrinted];
		[writer instruct:@"xml" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"1.0",@"version",@"UTF-8",@"encoding", nil]];
		[writer tag:@"loanDatabase" attributes:nil contentBlock:^{
			[writer tag:@"loans" attributes:nil contentBlock:^{
				[writer tag:@"loan" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"loan-123124",@"id",@"item-1231",@"itemID",@"friend-111",@"friendID", [NSNumber numberWithBool:NO], @"no",[NSNumber numberWithBool:YES], @"yes", nil] contentBlock:^{
					[writer text:@"This item has some content text!"];
				}];
			}];
			[writer tag:@"items" attributes:nil contentBlock:^{
				[writer tag:@"item" attributes:nil contentBlock:^{
					[writer tag:@"ImageData" attributes:nil contentBlock:^{
						[writer cdata:@"This is quite literally a end]]> cdata ]]> problem"];
					}];
				}];
			}];
			[writer tag:@"friends" attributes:nil contentBlock:^{
				
			}];
		}];
		NSLog(@"result XML:n\n%@", writer.XMLString);
		[writer release];
	}
		withTitle:@"Random XML"];

	
	[self addBlock:^{
		TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionPrettyPrinted];
		[writer instructXML];
		[writer tag:@"kml" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.opengis.net/kml/2.2",@"xmlns", nil] contentBlock:^{
			[writer tag:@"Document" attributes:nil contentBlock:^{
				[writer tag:@"Placemark" attributes:nil contentBlock:^{
					[writer tag:@"name" attributes:nil contentText:@"NYC"];
					[writer tag:@"description" attributes:nil contentText:@"New York City"];
					[writer tag:@"Point" attributes:nil contentBlock:^{
						[writer tag:@"coordinates" attributes:nil contentText:@"-74.006393,40.714172,0"];
					}];
				}];
			}];
		}];
		NSLog(@"result XML:\n%@", writer.XMLString);
		[writer release];
	}
		 withTitle:@"New York KML"];


	NSURL *fileURL = [self tempFileURL];
	[self addBlock:^{
		NSLog(@"auf gehts %s", __FUNCTION__);
		TCMXMLWriter *writer = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionPrettyPrinted fileURL:fileURL];
		[writer instructXML];
		[writer tag:@"parent" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"http://poop.la/parent",@"xmlns", nil] contentBlock:^{
			NSDictionary *attributeDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"abc",@"alphabet",[NSNumber numberWithBool:NO],@"boolean", nil];
			for (int i = 0; i<100000; i++) {
				[writer tag:@"item" attributes:attributeDictionary contentBlock:^{
					NSNumber *numberI = [[NSNumber alloc] initWithInt:i];
					NSDictionary *innerAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:numberI,@"index", nil];
					NSString *commentString = [[NSString alloc] initWithFormat:@"This is entry number: %d",i];
					[writer comment:commentString];
					[writer tag:@"just_tag" attributes:innerAttributes];
					[writer tag:@"text_tag" attributes:innerAttributes contentText:@"Some Content Text"];
					[writer tag:@"cdata_tag" attributes:innerAttributes contentCDATA:@"Some Content CDATA"];
					[innerAttributes release];
					[commentString release];
					[numberI release];
					}
				 ];
			}
			
			[attributeDictionary release];
		}];
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil];
		NSLog(@"result lengthInBytes:\n%@", fileAttributes);
		[writer release];
	}
		 withTitle:@"Big Ass XML File Write"];

}

- (void)addBlock:(void (^)(void))aBlock withTitle:(NSString *)aTitle {
	[contentArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:aTitle,kTitleKey,[[aBlock copy] autorelease],kBlockKey, nil]];
}

- (void (^)(void))blockAtIndex:(NSUInteger)anIndex {
	return (void (^)(void))[[contentArray objectAtIndex:anIndex] objectForKey:kBlockKey];
}

- (NSString *)titleAtIndex:(NSUInteger)anIndex {
	return [[contentArray objectAtIndex:anIndex] objectForKey:kTitleKey];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return contentArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	// Configure the cell.
	cell.textLabel.text = [self titleAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self blockAtIndex:indexPath.row]();
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)tempFileURL {
	NSURL *result = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tempFile.xml"]];
	NSLog(@"tempURL %@",result);
	return result;
}

@end
