//
//  HSBResult.h
//  hackerspacehb
//
//  Created by trailblazr on 12.09.13.
//  Hackerspace Bremen
//

#import "Jastor.h"

/*
 "RESULT": {
 "ST2": "1378722795402",
 "ST3": "OPEN",
 "ST5": ""
 },
*/

@interface HSBResult : Jastor {

    NSString *ST1;
    NSString *ST2;
    NSString *ST3;
    NSString *ST4;
    NSString *ST5;
    
}

@property( nonatomic, retain ) NSString *ST1;
@property( nonatomic, retain ) NSString *ST2;
@property( nonatomic, retain ) NSString *ST3;
@property( nonatomic, retain ) NSString *ST4;
@property( nonatomic, retain ) NSString *ST5;

+ (NSDictionary*) objectMapping;

- (NSDate*) dateOfLastChangeStatus;
- (BOOL) isOpenStatus;
- (NSString*) messageSpaceStatus;


@end
