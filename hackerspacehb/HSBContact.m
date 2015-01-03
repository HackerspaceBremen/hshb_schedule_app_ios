//
//  HSBContact.m
//  hackerspacehb
//
//  Created by trailblazr on 12.09.13.
//  Hackerspace Bremen
//

#import "HSBContact.h"

@implementation HSBContact

@synthesize twitter;
@synthesize phone;
@synthesize email;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"twitter", @"twitter",
                                 @"phone", @"phone",
                                 @"email",@"email",
                                 nil];
    return mappingDict;
}

- (NSString*) description {
	NSMutableString *description = [NSMutableString string];
    
	[description appendFormat:@" twitter = %@\n", twitter ];
	[description appendFormat:@"   phone = %@\n", phone ];
	[description appendFormat:@"   email = %@\n", email ];
    
	return (NSString*)description;
}

@end
