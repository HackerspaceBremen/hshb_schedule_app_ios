#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"
#import "Jastor.h"

@class HSBContact;
@class HSBResult;
@class HSBIcon;

@interface HSBStatus : Jastor {
    
    NSString *urlLogo;
    NSString *urlHackerspace;
    NSNumber *spaceLongitude;
    NSNumber *spaceLatitude;
    NSString *spaceName;
    NSString *spaceAddress;
    NSNumber *spaceIsOpen;
    NSString *spaceApiVersion;
    HSBContact *spaceContact;
    HSBResult *spaceResult;
    HSBIcon *spaceIcon;
    NSNumber *spaceLastchange;
    NSString *spaceStatusMessage;
    
}

@property(nonatomic, retain) NSString *urlLogo;
@property(nonatomic, retain) NSString *urlHackerspace;
@property(nonatomic, retain) NSNumber *spaceLongitude;
@property(nonatomic, retain) NSNumber *spaceLatitude;
@property(nonatomic, retain) NSString *spaceName;
@property(nonatomic, retain) NSString *spaceAddress;
@property(nonatomic, retain) NSNumber *spaceIsOpen;
@property(nonatomic, retain) NSString *spaceApiVersion;
@property(nonatomic, retain) HSBContact *spaceContact;
@property(nonatomic, retain) HSBResult *spaceResult;
@property(nonatomic, retain) HSBIcon *spaceIcon;
@property(nonatomic, retain) NSNumber *spaceLastchange;
@property(nonatomic, retain) NSString *spaceStatusMessage;

+ (NSDictionary*) objectMapping;

- (NSDate*) dateOfLastChangeStatus;

@end
