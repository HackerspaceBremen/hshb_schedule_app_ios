//
//  HSBError.m
//  hackerspacehb
//
//  Created by trailblazr on 14.09.13.
//  Hackerspace Bremen
//

#import "HSBError.h"

@implementation HSBError

@synthesize errorMessage;
@synthesize errorCode;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"errorMessage", @"ERROR",
                                 @"errorCode", @"CODE",
                                 nil];
    return mappingDict;
}

- (NSString*) description {
	NSMutableString *description = [NSMutableString string];
    
	[description appendFormat:@"     errorMessage = %@\n", errorMessage ];
	[description appendFormat:@"        errorCode = %@\n", errorCode ];
    
	return (NSString*)description;
}

@end
