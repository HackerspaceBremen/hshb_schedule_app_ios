//
//  AppDelegate.m
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import "AppDelegate.h"
#import "FDKeychain.h"

#import "EventDetailViewController.h"
#import "CalendarViewController.h"
#import "RootViewController.h"
#import "HSBApplication.h"

@implementation AppDelegate

@synthesize storedFavoriteEvents;
@synthesize hackerspaceBremenStatus;
@synthesize hasRefreshedDataAfterStartup;
@synthesize dateAppWentToBackground;
@synthesize backgroundFetchStartDate;
@synthesize backgroundFetchDoneDate;
@synthesize wasInstall;
@synthesize wasUpdate;
@synthesize dateOnBecomeActive;

#pragma mark - destruction

- (void)dealloc {
    [_window release];
    [_rootNavController release];
    self.storedFavoriteEvents = nil;
    self.hackerspaceBremenStatus = nil;
    self.backgroundFetchStartDate = nil;
    self.backgroundFetchDoneDate = nil;
    self.dateOnBecomeActive = nil;
    [super dealloc];
}

#pragma mark - convenience methods

- (UIApplication*)application {
    return [UIApplication sharedApplication];
}

- (void) ensureSafeStorage {
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    if( uid ) { // transfer
        [self tokenStore:uid withKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    }
    if( pwd ) { // transfer
        [self tokenStore:pwd withKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) tokenStore:(NSString*)token withKey:(NSString*)key {
    NSError *error = nil;
    [FDKeychain saveItem:token forKey:key forService:kKEYCHAIN_GROUP_NAME_KEY error:&error];
    if( error ) {
        //LOG( @"ERROR: WRITING ITEM SAFELY TO KEYCHAIN." );
    }
    //LOG( @"SAVED TOKEN (%@): %@", key, token );
}

- (NSString*) tokenStoredWithKey:(NSString*)key {
    NSError *error = nil;
    NSString *token = (NSString*)[FDKeychain itemForKey:key forService:kKEYCHAIN_GROUP_NAME_KEY error:&error];
    if( error ) {
        //LOG( @"ERROR: READING ITEM SAFELY FROM KEYCHAIN." );
    }
    else {
        
    }
    //LOG( @"RESTORED TOKEN( %@ ): %@", key, token );
    return token;
}

- (NSInteger) numberOfLaunches {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kUSERDEFAULT_LAUNCH_COUNT];
}

- (void) doLaunchChecks {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // count launches
    if( ![defaults objectForKey:kUSERDEFAULT_LAUNCH_COUNT] ) {
        [defaults setInteger:0 forKey:kUSERDEFAULT_LAUNCH_COUNT];
        [defaults synchronize];
    }
    else {
        NSInteger countedLaunches = [defaults integerForKey:kUSERDEFAULT_LAUNCH_COUNT];
        countedLaunches++;
        [defaults setInteger:countedLaunches forKey:kUSERDEFAULT_LAUNCH_COUNT];
        [defaults synchronize];
    }
    // detect if new version arrived or fresh install
    self.wasInstall = NO;
    self.wasUpdate = NO;
    if( ![defaults objectForKey:kUSERDEFAULT_INSTALLED_VERSION] ) {
        self.wasInstall = YES;
    }
    else {
        NSString *existingVersion = [defaults objectForKey:kUSERDEFAULT_INSTALLED_VERSION];
        NSString *currentVersion = [HSBApplication versionStringShort];
        if( ![existingVersion isEqualToString:currentVersion] ) {
            self.wasUpdate = YES;
        }
    }
}

#pragma mark - convenience for favorites

- (void) eventFavoritesRead {
    NSString *pathToCacheFile = [USER_OFFLINEDATA_FOLDER stringByAppendingPathComponent:kOFFLINE_EVENT_FAVORITES_FILENAME];
    NSDictionary *dictionaryRead = nil;
    @try {
        dictionaryRead = [NSDictionary dictionaryWithContentsOfFile:pathToCacheFile];
        LOG( @"READ %lu FAVS.", (unsigned long)[[dictionaryRead allKeys] count] );
    }
    @catch (NSException *exception) {
        LOG( @"ERROR WRITING FAVS." );
    }
    if( !dictionaryRead ) {
        self.storedFavoriteEvents = [NSMutableDictionary dictionary];
    }
    else {
        self.storedFavoriteEvents = [NSMutableDictionary dictionaryWithDictionary:dictionaryRead];
    }
}

- (void) eventFavoritesWrite {
    NSString *pathToCacheFile = [USER_OFFLINEDATA_FOLDER stringByAppendingPathComponent:kOFFLINE_EVENT_FAVORITES_FILENAME];
    NSDictionary *dictionaryToWrite = (NSDictionary*)storedFavoriteEvents;
    @try {
        [dictionaryToWrite writeToFile:pathToCacheFile atomically:YES];
        LOG( @"WRITTEN %lu FAVS.", (unsigned long)[[dictionaryToWrite allKeys] count] );
    }
    @catch (NSException *exception) {
        LOG( @"ERROR WRITING FAVS." );
    }
}

- (void) addToFavoritesEvent:(GoogleCalendarEvent*)event {
    [storedFavoriteEvents setObject:event.Title forKey:event.uniqueId];
    [self eventFavoritesWrite];
    [event markAsFavorite];
    LOG( @"ADDED EVENT: %@", event.Title );
}

- (void) removeFromFavoritesEvent:(GoogleCalendarEvent*)event {
    [storedFavoriteEvents removeObjectForKey:event.uniqueId];
    [self eventFavoritesWrite];
    [event unmarkAsFavorite];
    LOG( @"REMOVED EVENT: %@", event.Title );
}

#pragma mark - push notifications

- (void) enableNotifications {
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert +UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // Enable or disable features based on authorization.
        
    }];}

- (IBAction) actionScheduleTestNotification {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Lokale Nachricht";
    content.body = @"Fick dich Apple!";
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:25 repeats:NO];
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"0001" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
        //
    }];
}

#pragma mark - background fetches

- (void) enableBackgroundFetching {
        if( DEBUG_BACKGROUND ) NSLog( @"APPDELEGATE: ENABLING BACKGROUND FETCHING" );
        NSTimeInterval backgroundFetchInterval = 10 * 60; // 30 Minutes
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:backgroundFetchInterval];
}

- (void) disableBackgroundFetching {
        if( DEBUG_BACKGROUND ) NSLog( @"APPDELEGATE: DISABLING BACKGROUND FETCHING" );
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if( DEBUG_BACKGROUND ) NSLog( @"BACKGROUND: FETCHING STUFF NOW..." );
    self.backgroundFetchStartDate = [NSDate date];
    
    // configure network session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Accept":@"application/json"};
    NSURLSession *mySession = [NSURLSession sessionWithConfiguration:configuration];
    NSString *urlString = [kHACKERSPACE_API_BASE_URL stringByAppendingString:@"status"];
    if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|CONFIGURING: %@", urlString );
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDataTask *task = [mySession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.backgroundFetchDoneDate = [NSDate date];
        NSTimeInterval timeElapsed = [backgroundFetchDoneDate timeIntervalSinceDate:backgroundFetchStartDate];
        if( DEBUG_BACKGROUND ) NSLog( @"BACKGROUND: FETCH NEEDED %.2f SECONDS...", timeElapsed );
        if( error ) {
            if( DEBUG_BACKGROUND ) NSLog(@"BACKFETCH|ERROR:\n%@", error);
            if( completionHandler ) {
                completionHandler(UIBackgroundFetchResultFailed);
            }
        }
        else {
            //NSLog(@"TASK|RESPONSE:\n%@", response);
            if( data ) {
                NSError *jsonParseError = nil;
                id jsonObject = nil;
                @try {
                    jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParseError];
                } @catch (NSException *exception) {
                    if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|JSON ERROR:\n%@", jsonParseError );
                }
                
                if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|DATA:\n%@", jsonObject );
                HSBStatus *fetchedStatus= [[HSBStatus class] objectFromJSONObject:(id<JTValidJSONResponse>)jsonObject mapping:[[HSBStatus class] objectMapping]];
                if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH STATUS RECEIVED:\n%@\n", fetchedStatus );
                BOOL statusOpenBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kUSER_DEFAULTS_LAST_SPACE_STATUS];
                // statusOpenBefore = YES;
                if( completionHandler ) {
                    if( statusOpenBefore != [fetchedStatus.spaceIsOpen boolValue] ) {
                        if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|STATUS WAS CHANGED: %@", statusOpenBefore ? @"OPEN -> CLOSED" : @"CLOSED -> OPEN" );
                        [[NSUserDefaults standardUserDefaults] setBool:[fetchedStatus.spaceIsOpen boolValue] forKey:kUSER_DEFAULTS_LAST_SPACE_STATUS];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSString *niceFormattedDate = nil;
                        if( [fetchedStatus dateOfLastChangeStatus] ) {
                            niceFormattedDate = [NSString stringWithFormat:@"%@", [fetchedStatus dateOfLastChangeStatus]];
                            @try {
                                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                df.doesRelativeDateFormatting = NO;
                                // df.timeZone = [[[NSTimeZone alloc] initWithName:@"GMT+2"] autorelease];
                                df.timeStyle = NSDateFormatterShortStyle;
                                df.dateStyle = NSDateFormatterMediumStyle;
                                niceFormattedDate = [df stringFromDate:[fetchedStatus dateOfLastChangeStatus]];
                                [df release];
                            }
                            @catch (NSException *exception) {
                                //
                            }
                        }
                        
                        NSString *timeChangedString = nil;
                        if( niceFormattedDate ) {
                            timeChangedString = [NSString stringWithFormat:@"seit %@ Uhr Ortszeit ", niceFormattedDate];
                        }
                        
                        // schedule notification
                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                        
                        // prepare text
                        BOOL isOpen = [fetchedStatus.spaceIsOpen boolValue];
                        content.title = isOpen ? @"Offen" : @"Geschlossen";
                        NSString *bodyOpen = [NSString stringWithFormat:@"Der Hackerspace Bremen ist jetzt für dich %@geöffnet.", timeChangedString ? timeChangedString : @""];
                        NSString *bodyClosed = [NSString stringWithFormat:@"Der Hackerspace Bremen hat leider %@geschlossen.", timeChangedString ? timeChangedString : @""];
                        NSString *message = fetchedStatus.spaceStatusMessage ? fetchedStatus.spaceStatusMessage : @"";
                        content.body = isOpen ? bodyOpen : bodyClosed;
                        content.sound = [UNNotificationSound defaultSound];
                        NSString *currentStatus = isOpen ? @"OPEN" : @"CLOSED";
                        content.userInfo = @{@"status":currentStatus,@"message":message};
                        content.categoryIdentifier = @"SPACE_STATUS_CATEGORY"; // for notification extension
                        
                        // add attachment
                        NSURL *imageUrlSign = [NSBundle URLForResource:isOpen ? @"sign_green_large" : @"sign_red_large" withExtension:@"png" subdirectory:nil inBundleWithURL:[[NSBundle mainBundle] bundleURL]];
                        NSError *error = nil;
                        UNNotificationAttachment *attachment1 = [UNNotificationAttachment attachmentWithIdentifier:@"sign" URL:imageUrlSign options:@{} error:&error];
                        content.attachments = @[attachment1];
                        
                        // craft notification
                        NSString *notificationIdentifier = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
                        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
                        UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:notificationIdentifier content:content trigger:trigger];
                        
                        // actually send notification
                        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:notificationRequest withCompletionHandler:^(NSError * _Nullable error) {
                            //
                        }];
                        completionHandler(UIBackgroundFetchResultNewData);
                    }
                    else {
                        if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|STATUS WAS UNCHANGED!!" );
                        completionHandler(UIBackgroundFetchResultNoData);
                    }
                }
            }
            else {
                if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|DATA:\nNONE." );
                if( completionHandler ) {
                    if( completionHandler ) {
                        completionHandler(UIBackgroundFetchResultFailed);
                    }
                }
            }
        }
    }];
    if( DEBUG_BACKGROUND ) NSLog( @"BACKFETCH|STARTING: %@", urlString );
    [task resume]; // kick off connection
}


#pragma mark - app status

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.hasRefreshedDataAfterStartup = NO;
    [self enableBackgroundFetching];
    UINavigationBar *proxyNavigationBar = [UINavigationBar appearance];
    proxyNavigationBar.barTintColor = [kCOLOR_HACKERSPACE colorWithAlphaComponent:0.8];
    proxyNavigationBar.tintColor = kCOLOR_HACKERSPACE_WHITE;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:17.0], NSFontAttributeName, kCOLOR_HACKERSPACE_WHITE, NSForegroundColorAttributeName, nil];
    [proxyNavigationBar setTitleTextAttributes:attributes];
    
    UIToolbar *proxyToolbar = [UIToolbar appearance];
    proxyToolbar.barTintColor = [kCOLOR_HACKERSPACE colorWithAlphaComponent:0.8];
    proxyToolbar.tintColor = kCOLOR_HACKERSPACE_WHITE;
    
    UISlider *proxySlider = [UISlider appearance];
    proxySlider.minimumTrackTintColor = kCOLOR_HACKERSPACE;
    proxySlider.maximumTrackTintColor = [[UIColor whiteColor] colorByDarkeningTo:0.8];
    
    UISwitch *proxySwitch = [UISwitch appearance];
    proxySwitch.onTintColor = kCOLOR_HACKERSPACE;
    
    // NSLog( @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD] );
    
    // SETUP NETWORKING
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [URLCache release];
    
    // READ FAVORITE EVENTS
    [self eventFavoritesRead];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.tintColor = kCOLOR_HACKERSPACE;//[UIColor whiteColor];

    CalendarViewController *firstController = [[[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil] autorelease];
    
    self.rootNavController = [[[RootViewController alloc] initWithRootViewController:firstController] autorelease];
    self.window.rootViewController = self.rootNavController;
    UIImage *indicatorImage = [UIImage imageNamed:@"icon_back_elegant"];
    indicatorImage = [indicatorImage imageWithAlignmentRectInsets:UIEdgeInsetsMake(4.0f, 0, 4.0f, 0)];
    indicatorImage = [indicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.rootNavController.navigationBar.backIndicatorImage = indicatorImage;
    self.rootNavController.navigationBar.backIndicatorTransitionMaskImage = indicatorImage;

    [self ensureSafeStorage];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.dateAppWentToBackground = [NSDate date];
    BOOL statusOpenBefore = [[NSUserDefaults standardUserDefaults] boolForKey:kUSER_DEFAULTS_LAST_SPACE_STATUS];
    if( DEBUG_BACKGROUND ) NSLog( @"applicationDidEnterBackground|STATUSBEFORE = %@", statusOpenBefore? @"OPEN" : @"CLOSED" );
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self doLaunchChecks];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_APP_GOES_ACTIVE object:nil];
    self.dateOnBecomeActive = [NSDate date];

    // CHECK IF WE NEED TO REFRESH DATA
    BOOL shouldNotifyAboutTimeChange = NO;
    if( dateAppWentToBackground ) {
        NSDate *dateNow = [NSDate date];
        NSUInteger units = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *componentsNow = [calendar components:units fromDate:dateNow];
        NSInteger yearNow = componentsNow.year;
        NSInteger monthNow = componentsNow.month;
        NSInteger dayNow = componentsNow.day;

        NSDateComponents *componentsThen = [calendar components:units fromDate:dateAppWentToBackground];
        NSInteger yearThen = componentsThen.year;
        NSInteger monthThen = componentsThen.month;
        NSInteger dayThen = componentsThen.day;

        if( yearNow != yearThen || monthNow != monthThen || dayNow != dayThen ) {
            shouldNotifyAboutTimeChange = YES;
        }
    }
    else {
        shouldNotifyAboutTimeChange = YES;
    }
    if( shouldNotifyAboutTimeChange ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_APP_DATE_TIME_CHANGED object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
