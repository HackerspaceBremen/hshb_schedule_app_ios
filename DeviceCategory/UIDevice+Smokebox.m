//
//  UIDevice+Smokebox.m
//  Smokebox
//
//  Created by Helge Staedtler on 19.09.11.
//  Copyright (c) 2011 Digineo GmbH. All rights reserved.
//

#import "UIDevice+Smokebox.h"
#import "NSString+AdditionEmpty.h"
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#import <sys/utsname.h>

@implementation UIDevice (Smokebox)

+ (NSInteger) systemVersion {
    return [[UIDevice currentDevice] versionAsInteger];
}

- (double) availableMemory {
    vm_statistics_data_t    vmStats;
    mach_msg_type_number_t    infoCount = HOST_VM_INFO_COUNT;
    mach_port_t                machHost = mach_host_self();
    kern_return_t            kernReturn = host_statistics(machHost, HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    if(KERN_SUCCESS != kernReturn) {
        return NSNotFound;
    }
    
    return (vm_page_size * vmStats.free_count);
}

- (NSString*) platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (BOOL) isDeviceGeneration4 {
    return ( [[self platform] isEqualToString:@"iPhone3,1"] || [[self platform] isEqualToString:@"iPod4,1"] || [[self platform] containsString:@"iPad2,"] );
}

- (BOOL) isDeviceGeneration5 {
    return ( [[self platform] isEqualToString:@"iPhone3,1"] || [[self platform] isEqualToString:@"iPod4,1"] || [[self platform] containsString:@"iPad2,"] );
}

- (NSString*) platformString {
    //
    // SEE LIST OF MODELS HERE: https://www.theiphonewiki.com/wiki/Models
    //
    NSMutableDictionary *platformDict = [NSMutableDictionary dictionary];
    [platformDict setValue:@"iPhone 1G"                 forKey:@"iPhone1,1"];
    
    [platformDict setValue:@"iPhone 3G"                 forKey:@"iPhone1,2"];
    [platformDict setValue:@"iPhone 3GS"                forKey:@"iPhone2,1"];
    
    [platformDict setValue:@"iPhone 4"                  forKey:@"iPhone3,1"];
    [platformDict setValue:@"iPhone 4 (Verizon)"        forKey:@"iPhone3,2"];
    [platformDict setValue:@"iPhone 4 (GSM)"            forKey:@"iPhone3,3"];
    
    [platformDict setValue:@"iPhone 4S"                 forKey:@"iPhone4,1"];
    [platformDict setValue:@"iPhone 4S (Verizon)"       forKey:@"iPhone4,2"];
    [platformDict setValue:@"iPhone 4S (GSM)"           forKey:@"iPhone4,3"];
    
    [platformDict setValue:@"iPhone 5 (GSM)"            forKey:@"iPhone5,1"];
    [platformDict setValue:@"iPhone 5 (Verizon/CDMA)"   forKey:@"iPhone5,2"];
    
    [platformDict setValue:@"iPhone 5c (GSM)"           forKey:@"iPhone5,3"];
    [platformDict setValue:@"iPhone 5c (Verizon/CDMA)"  forKey:@"iPhone5,4"];
    
    [platformDict setValue:@"iPhone 5s (GSM)"           forKey:@"iPhone6,1"];
    [platformDict setValue:@"iPhone 5s (Verizon/CDMA)"  forKey:@"iPhone6,2"];
    
    [platformDict setValue:@"iPhone 6"                  forKey:@"iPhone7,1"];
    [platformDict setValue:@"iPhone 6 Plus"             forKey:@"iPhone7,2"];
    
    [platformDict setValue:@"iPhone 6s"                 forKey:@"iPhone8,1"];
    [platformDict setValue:@"iPhone 6s Plus"            forKey:@"iPhone8,2"];
    
    [platformDict setValue:@"iPhone SE"                 forKey:@"iPhone8,4"];
    
    [platformDict setValue:@"iPhone 7"                  forKey:@"iPhone9,1"];
    [platformDict setValue:@"iPhone 7"                  forKey:@"iPhone9,3"];
    [platformDict setValue:@"iPhone 7 Plus"             forKey:@"iPhone9,2"];
    [platformDict setValue:@"iPhone 7 Plus"             forKey:@"iPhone9,4"];
    
    [platformDict setValue:@"iPhone 7"                  forKey:@"iPhone9,1"];
    [platformDict setValue:@"iPhone 7"                  forKey:@"iPhone9,3"];
    [platformDict setValue:@"iPhone 7 Plus"             forKey:@"iPhone9,2"];
    [platformDict setValue:@"iPhone 7 Plus"             forKey:@"iPhone9,4"];
    
    [platformDict setValue:@"iPhone 8"                  forKey:@"iPhone10,1"];
    [platformDict setValue:@"iPhone 8"                  forKey:@"iPhone10,4"];
    [platformDict setValue:@"iPhone 8 Plus"             forKey:@"iPhone10,2"];
    [platformDict setValue:@"iPhone 8 Plus"             forKey:@"iPhone10,5"];
    [platformDict setValue:@"iPhone X"                  forKey:@"iPhone10,3"];
    [platformDict setValue:@"iPhone X"                  forKey:@"iPhone10,6"];
    
    [platformDict setValue:@"iPod Touch 1G"             forKey:@"iPod1,1"];
    [platformDict setValue:@"iPod Touch 2G"             forKey:@"iPod2,1"];
    [platformDict setValue:@"iPod Touch 3G"             forKey:@"iPod3,1"];
    [platformDict setValue:@"iPod Touch 4G"             forKey:@"iPod4,1"];
    [platformDict setValue:@"iPod Touch 5G"             forKey:@"iPod5,1"];
    [platformDict setValue:@"iPod Touch 6G"             forKey:@"iPod7,1"];
    
    [platformDict setValue:@"iPad"                      forKey:@"iPad1,1"];
    
    [platformDict setValue:@"iPad 2 (WiFi)"             forKey:@"iPad2,1"];
    [platformDict setValue:@"iPad 2 (GSM)"              forKey:@"iPad2,2"];
    [platformDict setValue:@"iPad 2 (CDMA)"             forKey:@"iPad2,3"];
    
    [platformDict setValue:@"iPad mini (WiFi)"          forKey:@"iPad2,5"];
    [platformDict setValue:@"iPad mini (GSM)"           forKey:@"iPad2,6"];
    [platformDict setValue:@"iPad mini (CDMA)"          forKey:@"iPad2,7"];
    
    [platformDict setValue:@"iPad 3 (WiFi)"             forKey:@"iPad3,1"];
    [platformDict setValue:@"iPad 3 (CDMA)"             forKey:@"iPad3,2"];
    [platformDict setValue:@"iPad 3 (GSM)"              forKey:@"iPad3,3"];
    
    [platformDict setValue:@"iPad 4 (WiFi)"             forKey:@"iPad3,4"];
    [platformDict setValue:@"iPad 4 (GSM)"              forKey:@"iPad3,5"];
    [platformDict setValue:@"iPad 4 (CDMA)"             forKey:@"iPad3,6"];
    
    [platformDict setValue:@"iPad Air (WiFi)"           forKey:@"iPad4,1"];
    [platformDict setValue:@"iPad Air (GSM)"            forKey:@"iPad4,2"];
    [platformDict setValue:@"iPad Air"                  forKey:@"iPad4,3"];
    
    [platformDict setValue:@"iPad mini 2(WiFi)"         forKey:@"iPad4,4"];
    [platformDict setValue:@"iPad mini 2 (GSM)"         forKey:@"iPad4,5"];
    [platformDict setValue:@"iPad mini 2 (CDMA)"        forKey:@"iPad4,6"];
    
    [platformDict setValue:@"iPad mini 3 (WiFi)"        forKey:@"iPad4,7"];
    [platformDict setValue:@"iPad mini 3 (GSM)"         forKey:@"iPad4,8"];
    [platformDict setValue:@"iPad mini 3 (CDMA)"        forKey:@"iPad4,9"];
    
    [platformDict setValue:@"iPad mini 4 (WiFi)"        forKey:@"iPad5,1"];
    [platformDict setValue:@"iPad mini 4 (GSM)"         forKey:@"iPad5,2"];
    
    [platformDict setValue:@"iPad Air 2 (WiFi)"         forKey:@"iPad5,3"];
    [platformDict setValue:@"iPad Air 2 (GSM)"          forKey:@"iPad5,4"];
    
    [platformDict setValue:@"iPad Pro 9.7 (WiFi)"       forKey:@"iPad6,3"];
    [platformDict setValue:@"iPad Pro 9.7 (GSM)"        forKey:@"iPad6,4"];
    
    [platformDict setValue:@"iPad Pro 12.9 (WiFi)"      forKey:@"iPad6,7"];
    [platformDict setValue:@"iPad Pro 12.9 (GSM)"       forKey:@"iPad6,8"];
    
    [platformDict setValue:@"Simulator 386"             forKey:@"i386"];
    [platformDict setValue:@"Simulator x86 (64 bit)"    forKey:@"x86_64"];
    
    NSString *platform = [self platform];
    if( platform == nil || [platform length] == 0 ) return @"Unknown Platform";
    if( [platformDict valueForKey:platform] == nil ) {
        return platform;
    }
    else {
        return [NSString stringWithFormat:@"%@ / %@",[platformDict valueForKey:platform], platform];
    }
}

- (NSInteger) versionAsInteger {
    NSString *versionString = [self systemVersion];
    if( [versionString rangeOfString:@"."].location != NSNotFound ) {
        // EXTRACT CORRECT MAJOR VERSION
        NSUInteger index = [versionString rangeOfString:@"."].location;
        versionString = [versionString substringToIndex:index];
    }
    return [versionString intValue];
}

- (BOOL) isVersionEqualOrGreaterThanOS:(NSInteger)majorVersion {
    return( [self versionAsInteger] >= majorVersion );
}

+ (BOOL) isPod {
    return [[UIDevice currentDevice] isPod];
}

+ (BOOL) isTV {
    return [[UIDevice currentDevice] isTV];
}

+ (BOOL) isPad {
    return [[UIDevice currentDevice] isPad];
}

+ (BOOL) isPadPro {
    return [[UIDevice currentDevice] isPadPro];
}

+ (BOOL) isFon {
    return [[UIDevice currentDevice] isFon];
}

+ (BOOL) isFon5 {
    return [[UIDevice currentDevice] isFon5];
}

+ (BOOL) isFon6 {
    return [[UIDevice currentDevice] isFon6];
}

+ (BOOL) isFon6plus {
    return [[UIDevice currentDevice] isFon6plus];
}

+ (BOOL) isFonX {
    return [[UIDevice currentDevice] isFonX];
}

+ (BOOL) isRetina {
    return [[UIDevice currentDevice] isRetina];
}

- (BOOL) isPod {
    return ( [[[self platform] lowercaseString] rangeOfString:@"ipod"].location != NSNotFound );
}

- (BOOL) isTV {
    return( [UIDevice deviceType] == UIDeviceTypeTV || [UIDevice deviceType] == UIDeviceTypeTV4K );
}

- (BOOL) isPad {
    if( ![[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ) {
        return NO;
    }
    if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) {
        return NO;
    }
    return YES;
}

- (BOOL) isFon {
    return ![self isPad];
}

- (BOOL) isOS_2 {
    return ( [self versionAsInteger] >= 2 );
}

- (BOOL) isOS_3 {
    return ( [self versionAsInteger] >= 3 );
}

- (BOOL) isOS_4 {
    return ( [self versionAsInteger] >= 4 );
}

- (BOOL) isOS_5 {
    return ( [self versionAsInteger] >= 5 );
}

- (BOOL) isOS_6 {
    return ( [self versionAsInteger] >= 6 );
}

- (BOOL) isOS_7 {
    return ( [self versionAsInteger] >= 7 );
}

- (BOOL) isOS_8 {
    return ( [self versionAsInteger] >= 8 );
}

- (BOOL) isOS_9 {
    return ( [self versionAsInteger] >= 9 );
}

- (BOOL) isOS_10 {
    return ( [self versionAsInteger] >= 10 );
}

- (BOOL) isOS_11 {
    return ( [self versionAsInteger] >= 11 );
}

- (BOOL) isOS_12 {
    return ( [self versionAsInteger] >= 12 );
}

- (BOOL) isOS_13 {
    return ( [self versionAsInteger] >= 13 );
}

- (BOOL) isRetina {
    return ( [UIScreen mainScreen].scale == 2.0 );
}

+ (UIDeviceType) deviceType {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minSize = MIN( screenSize.width, screenSize.height );
    CGFloat maxSize = MAX( screenSize.width, screenSize.height );
    if( minSize == 320.0f && maxSize == 480.0f ) { // iPhone 1, 3, 3GS, 4, 4S
        return UIDeviceType35;
    }
    else if( minSize == 320.0f && maxSize == 568.0f ) { // iPhone 5, 5c, 5s
        return UIDeviceType40;
    }
    else if( minSize == 375.0f && maxSize == 667.0f ) { // iPhone 6, 6s
        return UIDeviceType47;
    }
    else if( minSize == 414.0f && maxSize == 736.0f ) { // iPhone 6 plus, iPhone 6 plus plus, iPhone 6 hyper retina
        return UIDeviceType55;
    }
    else if( minSize == 375.0f && maxSize == 812.0f ) { // iPhone X
        return UIDeviceType58;
    }
    else if( minSize == 768.0f && maxSize == 1024.0 ) {
        NSString *platformString =  [[[UIDevice currentDevice] platform] lowercaseString];
        NSArray *iPadMinis = @[ @"iPad2,5",@"iPad2,6",@"iPad2,7",@"iPad4,3",@"iPad4,4",@"iPad4,7",@"iPad4,8",@"iPad4,9",@"iPad5,1",@"iPad5,2"];
        for( NSString *currentModel in iPadMinis ) {
            if( [[currentModel lowercaseString] isEqualToString:platformString] ) { // iPad Mini
                return UIDeviceType79;
            }
        }
        return UIDeviceType97; // iPad (Normal)
    }
    else if( minSize == 2048.0f && maxSize == 2732.0f ) {
        NSString *platformString =  [[[UIDevice currentDevice] platform] lowercaseString];
        NSArray *iPadPros = @[ @"iPad6,7", @"iPad6,8"];
        for( NSString *currentModel in iPadPros ) {
            if( [[currentModel lowercaseString] isEqualToString:platformString] ) { // iPad Pro
                return UIDeviceType129;
            }
        }
        return UIDeviceType97; // iPad Pro Mini
    }
    else if( minSize == 1080.0f && maxSize == 1920.0f ) {
        return UIDeviceTypeTV; // Apple TV
    }
    else if( minSize == 2160.0f && maxSize == 3840.0f ) {
        return UIDeviceTypeTV4K; // Apple TV 4K
    }
    return UIDeviceTypeUnknown; // iPad Pro
}

+ (NSString*) deviceTypeString {
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString *deviceTypeName = nil;
    switch( [UIDevice deviceType] ) {
        case UIDeviceTypeUnknown:
            deviceTypeName = @"$iDevice ??? INCH";
            break;
        case UIDeviceType35:
            deviceTypeName = @"iPhone 3.5 INCH";
            break;
        case UIDeviceType40:
            deviceTypeName = @"iPhone 4.0 INCH";
            break;
        case UIDeviceType47:
            deviceTypeName = @"iPhone 4.7 INCH";
            break;
        case UIDeviceType55:
            deviceTypeName = @"iPhone 5.5 INCH";
            break;
        case UIDeviceType58:
            deviceTypeName = @"iPhone 5.8 INCH";
            break;
        case UIDeviceType79:
            deviceTypeName = @"iPad 7.9 INCH";
            break;
        case UIDeviceType97:
            deviceTypeName = @"iPad 9.7 INCH";
            break;
        case UIDeviceType129:
            deviceTypeName = @"iPad 12.9 INCH";
            break;
        case UIDeviceTypeTV:
            deviceTypeName = @"Apple TV";
            break;
        case UIDeviceTypeTV4K:
            deviceTypeName = @"Apple TV 4K";
            break;
        default:
            break;
    }
    // NSString *model = [[UIDevice currentDevice] model];
    // deviceTypeName = [NSString stringWithFormat:@"%@ %@", deviceTypeName, model];
    return [NSString stringWithFormat:@"%@ AT SCALE %0.f (%i x %i)", deviceTypeName, screenScale, (int)screenSize.width, (int)screenSize.height];
}

- (BOOL) isFon5 {
    return [UIDevice deviceType] == UIDeviceType40;
}

- (BOOL) isFon6 {
    return [UIDevice deviceType] == UIDeviceType47;
}

- (BOOL) isFonX {
    return [UIDevice deviceType] == UIDeviceType58;
}

- (BOOL) isFon6plus {
    return [UIDevice deviceType] == UIDeviceType55;
}

- (BOOL) isPadPro {
    return [UIDevice deviceType] == UIDeviceType129;
}

+ (CGFloat) randomFloatBetween:(CGFloat)smallNumber and:(CGFloat)bigNumber {
    CGFloat diff = bigNumber - smallNumber;
    CGFloat randomFloat = (((CGFloat) rand() / RAND_MAX) * diff) + smallNumber;
    return randomFloat;
}

+ (UIBarButtonItem*) barButtonItemWithImageName:(NSString*)imageName target:(id)target action:(SEL)selector label:(NSString*)accessibilityLabel hint:(NSString*)accessibilityHint {
    return [UIDevice barButtonItemWithImageName:(NSString*)imageName target:(id)target action:(SEL)selector label:(NSString*)accessibilityLabel hint:(NSString*)accessibilityHint buttonRef:NULL];
}

+ (UIImage*) circleImageWithColor:(UIColor*)colorTop andColor:(UIColor*)colorBottom {
    if( !colorBottom ) {
        colorBottom = [colorTop colorByLighteningTo:0.3];
        colorTop = [colorTop colorByDarkeningTo:0.9];
    }
    BOOL isRetina = [[UIDevice currentDevice] isRetina];
    CGFloat edgeLength = isRetina ? 40.0 : 20.0;
    CGSize circleSize = CGSizeMake(edgeLength, edgeLength);
    CGRect circleArea = CGRectMake(0.0, 0.0, edgeLength, edgeLength);
    UIImage *circleImage = nil;
    UIGraphicsBeginImageContext( circleSize );
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect( c, circleArea );
    CGContextSetFillColorWithColor(c, colorTop.CGColor );
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGPoint start, end;
    start = CGPointMake( floor(circleSize.width/2.0f), 0.0 );
    end = CGPointMake( floor(circleSize.width/2.0f), circleSize.height );
    /*
     CGFloat locations[2];
     locations[0] = 0.0;
     locations[1] = 1.0;
     */
    
    UIColor *uicolor1,*uicolor2;
    uicolor1 = colorTop;
    uicolor2 = colorBottom;
    
    const CGFloat* componentsColor1 = CGColorGetComponents( uicolor1.CGColor );
    int numOfColors1 = (int)CGColorGetNumberOfComponents( uicolor1.CGColor );
    const CGFloat* componentsColor2 = CGColorGetComponents( uicolor2.CGColor );
    int numOfColors2 = (int)CGColorGetNumberOfComponents( uicolor2.CGColor );
    
    // FIX BUG ON < IOS4
    CGColorRef color1,color2;
    if( numOfColors1 == 2 ) { // monochrome color
        color1 = [UIColor colorWithRed:componentsColor1[0] green:componentsColor1[0] blue:componentsColor1[0] alpha:componentsColor1[1]].CGColor;
    }
    else {
        color1 = [UIColor colorWithRed:componentsColor1[0] green:componentsColor1[1] blue:componentsColor1[2] alpha:componentsColor1[3]].CGColor;
    }
    if( numOfColors2 == 2 ) { // monochrome color
        color2 = [UIColor colorWithRed:componentsColor2[0] green:componentsColor2[0] blue:componentsColor2[0] alpha:componentsColor2[1]].CGColor;
    }
    else {
        color2 = [UIColor colorWithRed:componentsColor2[0] green:componentsColor2[1] blue:componentsColor2[2] alpha:componentsColor2[3]].CGColor;
    }
    
    NSArray *colors = [NSArray arrayWithObjects:(id)color1,(id)color2, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (CFArrayRef)colors, NULL );
    CGColorSpaceRelease(rgb);
    
    if( NO ) {
        CGPoint circleCenterStart = CGPointMake(circleArea.size.width/2.0, circleArea.size.height/2.0);
        CGPoint circleCenterEnd = CGPointMake(circleArea.size.width/2.0, circleArea.size.height/2.0);
        CGContextDrawRadialGradient(c, gradient, circleCenterStart, 0.5, circleCenterEnd, 1.0, kCGGradientDrawsAfterEndLocation);
    }
    // ADD CLIPPING CIRCLE
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:circleArea cornerRadius:circleSize.width/2.0].CGPath;
    CGContextAddPath( c, clippath );
    CGContextClip( c );
    
    CGContextDrawLinearGradient(c, gradient, start, end, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    circleImage = UIGraphicsGetImageFromCurrentImageContext();
    if( isRetina ) {
        circleImage = [UIImage imageWithCGImage:circleImage.CGImage scale:2 orientation:circleImage.imageOrientation];
    }
    UIGraphicsEndImageContext();
    return circleImage;
}


@end

