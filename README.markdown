# TCMXMLWriter - an elegant memory efficient XML Marshaller

## Design Goals
* small memory footprint during marshalling
* elegant syntax
* suitable for iOS & Mac
* self contained, no other dependencies

## Requirements
* iOS 4.x or higher
* Mac OS X 10.6.8 or higher, 64-bit only
* will probably be upped to Lion + iOS 5.0 soon

## Usage

You need to include the TCMXMLWriter.h/m in your project.

After that you initialize your TCMXMLWriter with either nothing (will write to memory) a file URL (will write as a stream to that URL) or a stream it will write to.

This is a example generating KML of New York:

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


The Attributes Dictionary can include these types as value:

* NSNumber (bools will be "yes" and "no", for other numbers it will be -[NSNumber stringValue]
* NSDate (will be encoded using ISO8601 with GMT - e.g. 2011-07-18T17:47:59Z )
* NSStrings which will be represented literally

For more api see the TCMXMLWriter.h

## Acknowledgements
* greatly inspired by the [ruby XML Builder](http://rubyforge.org/projects/builder/) framework
