#import "HSBIcon.h"

@implementation HSBIcon

@synthesize iconUrlOpen;
@synthesize iconUrlClosed;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"iconUrlOpen", @"open",
                                 @"iconUrlClosed", @"closed",
                                 nil];
    return mappingDict;
}

- (NSString*) description {
	NSMutableString *description = [NSMutableString string];
    
	[description appendFormat:@"        iconUrlOpen = %@\n", iconUrlOpen ];
	[description appendFormat:@"        iconUrlClosed = %@\n", iconUrlClosed ];
    
	return (NSString*)description;
}

@end
