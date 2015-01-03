#import <Foundation/Foundation.h>

@interface UIDevice (Smokebox)

+ (CGFloat) systemVersion;
+ (BOOL) isFon;
+ (BOOL) isFon5;
+ (BOOL) isPad;
+ (BOOL) isPod;
+ (BOOL) isRetina;

- (NSString*) platform;
- (NSString*) platformString;
- (NSInteger) versionAsInteger;
- (BOOL) isPad;
- (BOOL) isPod;
- (BOOL) isFon;
- (BOOL) isRetina;
- (BOOL) isDeviceGeneration4;
- (BOOL) isDeviceGeneration5;
- (BOOL) isVersionEqualOrGreaterThanOS:(NSInteger)majorVersion;

- (BOOL) isOS_2;
- (BOOL) isOS_3;
- (BOOL) isOS_4;
- (BOOL) isOS_5;
- (BOOL) isOS_6;
- (BOOL) isOS_7;
- (BOOL) isDevice4Inches;
- (BOOL) isFon5;

@end
