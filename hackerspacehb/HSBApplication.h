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

- (BOOL) openURL:(NSURL *)url;
- (BOOL) openInSafariURL:(NSURL *)url;

@end
