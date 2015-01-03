#import "Jastor.h"

/*
 "RESULT": {
 "ST2": "1378722795402",
 "ST3": "OPEN",
 "ST5": ""
 },
*/

@interface HSBIcon : Jastor {

    NSString *iconUrlOpen;
    NSString *iconUrlClosed;
    
}

@property( nonatomic, retain ) NSString *iconUrlOpen;
@property( nonatomic, retain ) NSString *iconUrlClosed;

+ (NSDictionary*) objectMapping;


@end
