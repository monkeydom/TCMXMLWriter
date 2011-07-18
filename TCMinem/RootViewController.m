//
//  RootViewController.m
//  TCMinem
//
//  Created by Dominik Wagner on 14.07.11.
//  Copyright 2011 TheCodingMonkeys. All rights reserved.
//

#import "RootViewController.h"
#import "TCMXMLWriter.h"

@implementation RootViewController

- (id)initWithStyle:(UITableViewStyle)aStyle {
	if ((self=[super initWithStyle:aStyle])) {
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (!contentArray) {
		contentArray = [[NSMutableArray alloc] initWithObjects:
											[NSDictionary dictionaryWithObjectsAndKeys:@"Random XML",@"title",^{
		
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
	},@"block",nil],
						[NSDictionary dictionaryWithObjectsAndKeys:@"New York KML",@"title",^{
			
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
		},@"block",nil],
											nil];
	}
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
	cell.textLabel.text = [[contentArray objectAtIndex:indexPath.row] objectForKey:@"title"];
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
	((void(^)(void))[[contentArray objectAtIndex:indexPath.row] objectForKey:@"block"])();
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

@end
