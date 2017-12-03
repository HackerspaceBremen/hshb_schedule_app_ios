//
//  UIDevice+Smokebox.h
//  Smokebox
//
//  Created by Helge Staedtler on 19.09.11.
//  Copyright (c) 2011 Digineo GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { // SCREEN DIMENSIONS IN INCHES
    UIDeviceTypeUnknown,
    UIDeviceType35, // (iPhone 3,4)
    UIDeviceType40, // (iPhone 5)
    UIDeviceType47, // (iPhone 6)
    UIDeviceType55, // (iPhone 6plus)
    UIDeviceType58, // (iPhone X)
    UIDeviceType79, // (all Mini iPads)
    UIDeviceType97, // (all normal & Air iPads)
    UIDeviceType129, // (iPad Pro)
    UIDeviceTypeTV, // (Apple TV)
    UIDeviceTypeTV4K, // (Apple TV 4K)
} UIDeviceType;

@interface UIDevice (Smokebox)

+ (NSInteger) systemVersion;
+ (BOOL) isFon;
+ (BOOL) isFon5;
+ (BOOL) isFon6;
+ (BOOL) isFon6plus;
+ (BOOL) isFonX;
+ (BOOL) isPad;
+ (BOOL) isPadPro;
+ (BOOL) isPod;
+ (BOOL) isTV;
+ (BOOL) isRetina;
+ (UIDeviceType) deviceType;
+ (NSString*) deviceTypeString;

+ (UIBarButtonItem*) barButtonItemWithImageName:(NSString*)imageName target:(id)target action:(SEL)selector label:(NSString*)accessibilityLabel hint:(NSString*)accessibilityHint;
+ (UIImage*) circleImageWithColor:(UIColor*)colorTop andColor:(UIColor*)colorBottom;

- (NSString*) platform;
- (NSString*) platformString;
- (NSInteger) versionAsInteger;
- (BOOL) isPad;
- (BOOL) isPod;
- (BOOL) isFon;
- (BOOL) isRetina;
- (BOOL) isTV;
- (BOOL) isDeviceGeneration4;
- (BOOL) isDeviceGeneration5;
- (BOOL) isVersionEqualOrGreaterThanOS:(NSInteger)majorVersion;

- (BOOL) isOS_2;
- (BOOL) isOS_3;
- (BOOL) isOS_4;
- (BOOL) isOS_5;
- (BOOL) isOS_6;
- (BOOL) isOS_7;
- (BOOL) isOS_8;
- (BOOL) isOS_9;
- (BOOL) isOS_10;
- (BOOL) isFon5;

@end

