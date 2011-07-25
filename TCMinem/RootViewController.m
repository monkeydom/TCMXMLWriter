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

- (void)viewDidLoad
{
	[super viewDidLoad];
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
			for (int i = 0; i<10000; i++) {
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


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return contentArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	// Configure the cell.
	cell.textLabel.text = [self titleAtIndex:indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
	[self blockAtIndex:indexPath.row]();
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
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
