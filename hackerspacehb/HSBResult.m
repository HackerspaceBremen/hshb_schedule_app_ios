//
//  HSBResult.m
//  hackerspacehb
//
//  Created by trailblazr on 12.09.13.
//  Hackerspace Bremen
//

#import "HSBResult.h"

@implementation HSBResult

@synthesize ST1;
@synthesize ST2;
@synthesize ST3;
@synthesize ST4;
@synthesize ST5;

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"ST1", @"ST1",
                                 @"ST2", @"ST2",
                                 @"ST3", @"ST3",
                                 @"ST4", @"ST4",
                                 @"ST5", @"ST5",
                                 nil];
    return mappingDict;
}

- (NSString*) description {
	NSMutableString *description = [NSMutableString string];
    
	[description appendFormat:@"        ST1 = %@\n", ST1 ];
	[description appendFormat:@"        ST2 = %@\n", ST2 ];
	[description appendFormat:@"        ST3 = %@\n", ST3 ];
	[description appendFormat:@"        ST4 = %@\n", ST4 ];
	[description appendFormat:@"        ST5 = %@\n", ST5 ];
    
	return (NSString*)description;
}

- (NSDate*) dateOfLastChangeStatus {
    return [[[NSDate alloc] initWithTimeIntervalSince1970:[ST2 longLongValue]/1000.0] autorelease];
}

- (BOOL) isOpenStatus {
    return [ST3 isEqualToString:@"OPEN"];
}

- (NSString*) messageSpaceStatus {
    if( !ST5 || [ST5 length] == 0 ) return nil;
    return ST5;
}


@end
