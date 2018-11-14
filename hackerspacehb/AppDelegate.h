//
//  AppDelegate.h
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "GoogleCalendarEvent.h"
#import "HSBStatus.h"
#import "FDKeychain.h"
#import "RootViewController.h"

typedef enum {
    RemoteNotificationsAllowedNone = 0,
    RemoteNotificationsAllowedPartial = 1,
    RemoteNotificationsAllowedFull = 2,
} RemoteNotificationsAllowed;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    NSMutableDictionary *storedFavoriteEvents;
    HSBStatus *hackerspaceBremenStatus;
    BOOL hasRefreshedDataAfterStartup;
    NSDate *dateAppWentToBackground;
    NSDate *backgroundFetchStartDate;
    NSDate *backgroundFetchDoneDate;
    BOOL wasInstall;
    BOOL wasUpdate;
    NSDate *dateOnBecomeActive;
}

@property( nonatomic ) BOOL hasRefreshedDataAfterStartup;
@property( nonatomic ) BOOL wasInstall;
@property( nonatomic ) BOOL wasUpdate;
@property( retain, nonatomic ) NSMutableDictionary *storedFavoriteEvents;
@property( retain, nonatomic ) NSDate *dateAppWentToBackground;
@property( retain, nonatomic ) NSDate *backgroundFetchStartDate;
@property( retain, nonatomic ) NSDate *backgroundFetchDoneDate;
@property( strong, nonatomic ) UIWindow *window;
@property( strong, nonatomic ) RootViewController *rootNavController;
@property( strong, nonatomic ) HSBStatus *hackerspaceBremenStatus;
@property( strong, nonatomic ) NSDate *dateOnBecomeActive;

- (NSInteger) numberOfLaunches;
- (void) addToFavoritesEvent:(GoogleCalendarEvent*)event;
- (void) removeFromFavoritesEvent:(GoogleCalendarEvent*)event;
- (void) tokenStore:(NSString*)token withKey:(NSString*)key;
- (NSString*) tokenStoredWithKey:(NSString*)key;
- (void) enableNotifications;

- (IBAction) actionScheduleTestNotification;

@end
