//
//  HSBApplication.m
//  hackerspacehb
//
//  Created by trailblazr on 12.09.13.
//  Hackerspace Bremen
//

#import "HSBApplication.h"
#import "AppDelegate.h"

@implementation HSBApplication

+ (NSString*) versionStringVerbose {
    NSString *buildVersionString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *buildNumberString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSCalendarUnitYear );
    NSDateComponents *components = [calendar components:units fromDate:today];
    NSUInteger yearFrom = 2013;
    NSUInteger yearTo = components.year;
    return [NSString stringWithFormat:@"Hackerspace Bremen\nv%@ / build %@, %lu-%lu by trailblazr", buildVersionString, buildNumberString, (unsigned long)yearFrom, (unsigned long)yearTo];
}

+ (NSString*) versionStringShort {
    NSString *buildVersionString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *buildNumberString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ (%@)", buildVersionString, buildNumberString];
}

- (void) openURL:(NSURL *)url {
    NSString *urlAsString = [url absoluteString];
    LOG( @"OPENING URL INTERNALLY: %@", urlAsString );
    return [self openInSafariURL:url];
}

- (void) openInSafariURL:(NSURL *)url {
    NSString *urlAsString = [url absoluteString];
    LOG( @"OPENING URL IN SAFARI: %@", urlAsString );
    [super openURL:url options:@{} completionHandler:^(BOOL success) {
        // done
    }];
}

@end
