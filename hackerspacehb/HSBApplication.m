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

- (BOOL) openURL:(NSURL *)url {
    NSString *urlAsString = [url absoluteString];
    if( DEBUG ) NSLog( @"OPENING URL INTERNALLY: %@", urlAsString );
    return [self openInSafariURL:url];
}

- (BOOL) openInSafariURL:(NSURL *)url {
    NSString *urlAsString = [url absoluteString];
    if( DEBUG ) NSLog( @"OPENING URL IN SAFARI: %@", urlAsString );
    return [super openURL:url];
}

@end
