//
//  AppDelegate.h
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import <UIKit/UIKit.h>
#import "GoogleCalendarEvent.h"
#import "HSBStatus.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    NSMutableDictionary *storedFavoriteEvents;
    HSBStatus *hackerspaceBremenStatus;
    BOOL hasRefreshedDataAfterStartup;
    NSDate *dateAppWentToBackground;
}

@property( nonatomic ) BOOL hasRefreshedDataAfterStartup;
@property( retain, nonatomic ) NSMutableDictionary *storedFavoriteEvents;
@property( retain, nonatomic ) NSDate *dateAppWentToBackground;
@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) UINavigationController *rootNavController;
@property( strong, nonatomic ) HSBStatus *hackerspaceBremenStatus;

- (void) addToFavoritesEvent:(GoogleCalendarEvent*)event;
- (void) removeFromFavoritesEvent:(GoogleCalendarEvent*)event;

@end
