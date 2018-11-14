//
//  HSBApplication.h
//  hackerspacehb
//
//  Created by trailblazr on 12.09.13.
//  Hackerspace Bremen
//

#import <UIKit/UIKit.h>

@interface HSBApplication : UIApplication {


}
+ (NSString*) versionStringVerbose;
+ (NSString*) versionStringShort;

- (void) openURL:(NSURL *)url;
- (void) openInSafariURL:(NSURL *)url;

@end
