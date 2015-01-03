#import "HSBStatus.h"
#import "HSBContact.h"
#import "HSBResult.h"
#import "HSBIcon.h"

@implementation HSBStatus

@synthesize urlLogo;
@synthesize urlHackerspace;
@synthesize spaceLongitude;
@synthesize spaceLatitude;
@synthesize spaceName;
@synthesize spaceAddress;
@synthesize spaceIsOpen;
@synthesize spaceApiVersion;
@synthesize spaceContact;
@synthesize spaceResult;
@synthesize spaceIcon;
@synthesize spaceLastchange;
@synthesize spaceStatusMessage;
/*
 
 https://hackerspacehb.appspot.com/v2/status
 
 {
 "icon": {
 "open": "http:\/\/hackerspacehb.appspot.com\/images\/status_auf_48px.png",
 "closed": "http:\/\/hackerspacehb.appspot.com\/images\/status_zu_48px.png"
 },
 "logo": "http:\/\/hackerspacehb.appspot.com\/images\/hackerspace_icon.png",
 "SUCCESS": "Status found",
 "url": "http:\/\/www.hackerspace-bremen.de",
 "lon": 8.8058309555054,
 "lat": 53.08177947998
 "status": "",
 "space": "Hackerspace Bremen e.V.",
 "address": "Bornstrasse 14\/15, 28195 Bremen, Germany",
 "lastchange": 1378722795,
 "contact": {
 "twitter": "@hspacehb",
 "phone": "+49 421 14 62 92 15",
 "email": "info@hackerspace-bremen.de"
 },
 "open": true,
 "RESULT": {
 "ST2": "1378722795402",
 "ST3": "OPEN",
 "ST5": ""
 },
 "api": "0.12",
 }
 */

+ (NSDictionary*) objectMapping {
    NSDictionary *mappingDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"urlLogo", @"logo",
                                 @"urlIconOpen", @"icon.open",
                                 @"urlIconClosed",@"icon.closed",
                                 @"urlHackerspace",@"url",
                                 @"spaceLongitude",@"lon",
                                 @"spaceLatitude",@"lat",
                                 @"spaceName",@"space",
                                 @"spaceAddress",@"address",
                                 @"spaceIsOpen",@"open",
                                 @"spaceApiVersion",@"api",
                                 [HSBContact mappingWithKey:@"spaceContact" mapping:[HSBContact objectMapping]],@"contact",
                                 [HSBResult mappingWithKey:@"spaceResult" mapping:[HSBResult objectMapping]],@"RESULT",
                                 [HSBIcon mappingWithKey:@"spaceIcon" mapping:[HSBIcon objectMapping]],@"icon",
                                 @"spaceLastchange",@"lastchange",
                                 @"spaceStatusMessage",@"status",
                                 nil];
    return mappingDict;
}

- (NSString*) description {
	NSMutableString *description = [NSMutableString string];
    
	[description appendFormat:@"\n\n"];
	[description appendFormat:@"              urlLogo = %@\n", urlLogo ];
	[description appendFormat:@"       urlHackerspace = %@\n", urlHackerspace ];
	[description appendFormat:@"       spaceLongitude = %@\n", spaceLongitude ];
	[description appendFormat:@"        spaceLatitude = %@\n", spaceLatitude ];
	[description appendFormat:@"            spaceName = %@\n", spaceName ];
	[description appendFormat:@"         spaceAddress = %@\n", spaceAddress ];
	[description appendFormat:@"          spaceIsOpen = %@\n", spaceIsOpen ];
	[description appendFormat:@"      spaceApiVersion = %@\n", spaceApiVersion ];
	[description appendFormat:@"         spaceContact = %@\n", spaceContact ];
	[description appendFormat:@"          spaceResult = %@\n", spaceResult ];
	[description appendFormat:@"            spaceIcon = %@\n", spaceIcon ];
	[description appendFormat:@"      spaceLastchange = %@\n", spaceLastchange ]; // day only
	[description appendFormat:@"   spaceStatusMessage = %@\n", spaceStatusMessage ? spaceStatusMessage : @"[NIL]" ];
	[description appendFormat:@"     dateOfLastChange = %@\n", [self dateOfLastChangeStatus] ];

	return (NSString*)description;
}

/**
 * Need this because the other value is not precise enough
 **/
- (NSDate*) dateOfLastChangeStatus {
    return [spaceResult dateOfLastChangeStatus];
}

@end
