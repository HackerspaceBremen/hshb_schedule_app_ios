//
//  AppDelegate.m
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import "AppDelegate.h"

#import "EventDetailViewController.h"
#import "CalendarViewController.h"

#import "AFNetworkActivityIndicatorManager.h"

@implementation AppDelegate

@synthesize storedFavoriteEvents;
@synthesize hackerspaceBremenStatus;
@synthesize hasRefreshedDataAfterStartup;
@synthesize dateAppWentToBackground;

- (void)dealloc
{
    [_window release];
    [_rootNavController release];
    self.storedFavoriteEvents = nil;
    self.hackerspaceBremenStatus = nil;
    [super dealloc];
}

#pragma mark - convenience methods

- (UIApplication*)application {
    return [UIApplication sharedApplication];
}

#pragma mark - convenience for favorites

- (void) eventFavoritesRead {
    NSString *pathToCacheFile = [USER_OFFLINEDATA_FOLDER stringByAppendingPathComponent:kOFFLINE_EVENT_FAVORITES_FILENAME];
    NSDictionary *dictionaryRead = nil;
    @try {
        dictionaryRead = [NSDictionary dictionaryWithContentsOfFile:pathToCacheFile];
        if( DEBUG ) NSLog( @"READ %lu FAVS.", (unsigned long)[[dictionaryRead allKeys] count] );
    }
    @catch (NSException *exception) {
        if( DEBUG ) NSLog( @"ERROR WRITING FAVS." );
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
        if( DEBUG ) NSLog( @"WRITTEN %lu FAVS.", (unsigned long)[[dictionaryToWrite allKeys] count] );
    }
    @catch (NSException *exception) {
        if( DEBUG ) NSLog( @"ERROR WRITING FAVS." );
    }
}

- (void) addToFavoritesEvent:(GoogleCalendarEvent*)event {
    [storedFavoriteEvents setObject:event.Title forKey:event.uniqueId];
    [self eventFavoritesWrite];
    [event markAsFavorite];
    if( DEBUG ) NSLog( @"ADDED EVENT: %@", event.Title );
}

- (void) removeFromFavoritesEvent:(GoogleCalendarEvent*)event {
    [storedFavoriteEvents removeObjectForKey:event.uniqueId];
    [self eventFavoritesWrite];
    [event unmarkAsFavorite];
    if( DEBUG ) NSLog( @"REMOVED EVENT: %@", event.Title );
}

#pragma mark - app status

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.hasRefreshedDataAfterStartup = NO;
    // WHITE STATUSBAR (HELL WTF OF LIMBO TO MAKE THIS WHITE)
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

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
    
    UIAlertView *proxyAlertView = [UIAlertView appearance];
    proxyAlertView.tintColor = kCOLOR_HACKERSPACE;

    
    // NSLog( @"%@", [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD] );
    
    // SETUP NETWORKING
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [URLCache release];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // READ FAVORITE EVENTS
    [self eventFavoritesRead];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.tintColor = [UIColor whiteColor];

    CalendarViewController *firstController = [[[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil] autorelease];
    self.rootNavController = [[[UINavigationController alloc] initWithRootViewController:firstController] autorelease];
    self.window.rootViewController = self.rootNavController;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.dateAppWentToBackground = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_APP_GOES_ACTIVE object:nil];

    // CHECK IF WE NEED TO REFRESH DATA
    BOOL shouldNotifyAboutTimeChange = NO;
    if( dateAppWentToBackground ) {
        NSDate *dateNow = [NSDate date];
        NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit );
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - pushnotifications

/*
- (NSString*) wellFormedPushToken {
    NSData *pushTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_DATA_PUSH_TOKEN];
    NSString *deviceToken = [[pushTokenData stringWithHexBytes] lowercaseString];
    if( !deviceToken || [deviceToken length] == 0 ) return @"";
    // CHECK FOR SPACES ALL 8 CHARS
    if( ![deviceToken rangeOfString:@" "].length ) {
        NSMutableString* tempString =  [NSMutableString stringWithString:deviceToken];
        int offset = 0;
        for( int i = 0; i < tempString.length; i++ ) {
            if( i % 8 == 0 && i != 0 && i+offset < tempString.length-1 ) {
                [tempString insertString:@" " atIndex:i+offset];
                offset++;
            }
        }
        deviceToken = [NSString stringWithString:tempString];
    }
    return deviceToken;
}

- (void) actionCheckEnabledPushNotifications {
    UIRemoteNotificationType enabledTypes = [[self application] enabledRemoteNotificationTypes];
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: ENABLED TYPES ARE..." );
    if( enabledTypes & UIRemoteNotificationTypeNone ) {
        if( DEBUG ) NSLog( @"- NONE" );
    }
    if( enabledTypes & UIRemoteNotificationTypeBadge ) {
        if( DEBUG ) NSLog( @"- BADGE" );
    }
    if( enabledTypes & UIRemoteNotificationTypeAlert ) {
        if( DEBUG ) NSLog( @"- ALERT" );
    }
    if( enabledTypes & UIRemoteNotificationTypeSound ) {
        if( DEBUG ) NSLog( @"- SOUND" );
    }
}

- (void) actionRegisterForPushNotifications {
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: TRIGGERED REGISTRATION" );
    // REGISTER FOR ALL TYPES
    [[self application] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// if( DEBUG ) NSLog( @"PUSHNOTIFICATION: REGISTERED WITH TOKEN '%@'", deviceToken );
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: REGISTERED WITH TOKEN AS STRING '%@'", [[deviceToken stringWithHexBytes] lowercaseString] );
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kUSER_DEFAULTS_DATA_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUSER_DEFAULTS_BOOL_HAS_SUBMITTED_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self actionPostPushToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: REGISTRATION FAILED. ERROR: %@", error );
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUSER_DEFAULTS_BOOL_HAS_SUBMITTED_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


 // If you implement application:didFinishLaunchingWithOptions: to handle an
 // incoming push notification that causes the launch of the application,
 // this method is not invoked for that push notification.

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: REMOTE NOTIFICATION RECEIVED USERINFO = %@", userInfo );
    BOOL didAppBecomeActiveImmediatelyBeforeThis = ( [dateOnBecomeActive timeIntervalSinceNow] > -5.0 );
    [self processPushNotificationsWithDictionary:userInfo afterLaunch:didAppBecomeActiveImmediatelyBeforeThis];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: LOCAL NOTIFICATION RECEIVED %@", notification );
    NSDictionary *userInfo = notification.userInfo;
    if( [[userInfo objectForKey:@"action"] isEqualToString:kNOTIFICATION_ALERT_ACTION_REQUESTS_SUBMITTED] ) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Anfragen übermittelt" message:notification.alertBody];
        [alert addButtonWithTitle:@"OK" block:^{
            //
        }];
        [alert show];
    }
    else {
        NSString *alertMessage = [NSString stringWithFormat:@"%@\n\nalertAction = %@\nalertLaunchImage = %@\napplicationIconBadgeNumber = %i\nsoundName = %@\n", notification.alertBody, notification.alertAction, notification.alertLaunchImage, notification.applicationIconBadgeNumber, notification.soundName];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Local Notification" message:alertMessage];
        [alert addButtonWithTitle:@"OK" block:^{
            //
        }];
        [alert show];
    }
}

#pragma mark - push token delete

- (IBAction) actionDeletePushToken {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: DELETING PUSH TOKEN... %@", [self wellFormedPushToken] );
    NSString *query = [NSString stringWithFormat:@"app/notification_tokens/%@", newEncodeToPercentEscapeString([self wellFormedPushToken])];
    NXJSONConnectOperation *operation = [NXJSONConnectOperation operationWithConnectUrl:[NSURL URLWithString:kSERVER_URL] andPathComponent:query delegate:self selFail:@selector(operationFailedDeletePushToken:) selSuccess:@selector(operationSuccessDeletePushToken:)];
    operation.jsonObjectClass = [User class];
    operation.jsonMappingDictionary = [User objectMapping];
    operation.isOperationDebugEnabled = YES;
    operation.credentials = [NXJSONConnectCredentials fromKeychain];
    ASIFormDataRequest *formDataRequest = [operation requestPostFormDataWithTimeoutInterval:60.0];
    formDataRequest.requestMethod = @"DELETE";
    [[NXJSONConnector instance] operationInitiate:operation];
}

- (void) operationSuccessDeletePushToken:(NXJSONConnectOperation *)operation {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: DELETE SUCCEEDED." );
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUSER_DEFAULTS_BOOL_HAS_SUBMITTED_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kUSER_DEFAULTS_DATA_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) operationFailedDeletePushToken:(NXJSONConnectOperation *)operation {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: DELETE FAILED." );
}

#pragma mark - posh token transmit

- (IBAction) actionPostPushToken {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: TRANSFERRING PUSH TOKEN... %@", [self wellFormedPushToken] );
    NSString *query = @"app/notification_tokens";
    NXJSONConnectOperation *operation = [NXJSONConnectOperation operationWithConnectUrl:[NSURL URLWithString:kSERVER_URL] andPathComponent:query delegate:self selFail:@selector(operationFailedPushToken:) selSuccess:@selector(operationSuccessPushToken:)];
    operation.jsonObjectClass = [User class];
    operation.jsonMappingDictionary = [User objectMapping];
    operation.isOperationDebugEnabled = YES;
    operation.credentials = [NXJSONConnectCredentials fromKeychain];
    ASIFormDataRequest *formDataRequest = [operation requestPostFormDataWithTimeoutInterval:60.0];
    formDataRequest.requestMethod = @"POST";
    [formDataRequest addPostValue:[self wellFormedPushToken] forKey:@"notification_token[token]"];
    [formDataRequest addPostValue:@"ios" forKey:@"notification_token[device_type]"];
    [formDataRequest addPostValue:[UIDevice usersDeviceName] forKey:@"notification_token[device_name_user]"];
    [[NXJSONConnector instance] operationInitiate:operation];
}

- (void) operationSuccessPushToken:(NXJSONConnectOperation *)operation {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: TRANSFER SUCCEEDED." );
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUSER_DEFAULTS_BOOL_HAS_SUBMITTED_PUSH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) operationFailedPushToken:(NXJSONConnectOperation *)operation {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: TRANSFER FAILED." );
    NSLog( @"PUSHNOTIFICATION: TRANSFER FAILED WITH ERROR: %@", [operation.error plainString] );
}


- (IBAction) actionScheduleTestNotification {
    if( DEBUG ) NSLog( @"PUSHNOTIFICATION: SCHEDULED TEST NOTIFICATION." );
    UILocalNotification *testNotification = [[[UILocalNotification alloc] init] autorelease];
    testNotification.fireDate = [NSDate dateWithTimeInterval:25 sinceDate:[NSDate date]];
    if( YES ) { // SIMULATE REMOTE NOTIFICATION
        testNotification.alertAction = @"Anzeigen";
        testNotification.alertBody = @"Es wurden heute 7 Anfragen erfolgreich an Unternehmen zugestellt.";
        testNotification.userInfo = [NSDictionary dictionaryWithObject:kNOTIFICATION_ALERT_ACTION_REQUESTS_SUBMITTED forKey:@"action"];
        testNotification.soundName = @"audio_local_notification.caf";
    }
    else { // SIMULATE ANY TEST NOTIFICATION
        testNotification.alertAction = @"Zeigen";
        testNotification.alertBody = @"Dies ist eine lokale Benachrichtigung!";
        testNotification.userInfo = [NSDictionary dictionaryWithObject:kNOTIFICATION_ALERT_ACTION_TEST forKey:@"action"];
        testNotification.soundName = UILocalNotificationDefaultSoundName;
    }
    testNotification.alertLaunchImage = nil;
    testNotification.applicationIconBadgeNumber = 0;
    [[self application] scheduleLocalNotification:testNotification];
}

#pragma mark - process push & local notifications

- (void) processPushNotificationsWithDictionary:(NSDictionary *)userInfo afterLaunch:(BOOL)comesFromLaunch {
	if( DEBUG ) NSLog( @"PUSHNOTIFICATION: PROCESSING INCOMING NOTIFICATION" );
    
    NXPushNotification *receivedNotification = [NXPushNotification notificationFromPushDictionaryOptions:userInfo];
    receivedNotification.wasReceivedInBackground = comesFromLaunch;
    NSLog( @"PUSHNOTIFICATION: RECEIVED %@", receivedNotification );
    
    [receivedNotification showInView:[self rootNavigationController].topViewController.view];
    
    if( NO ) {
        // STEP 0: if we have launched from background we don't need to display the message again
        // STEP 1: check if we got some action url
        // STEP 2: alert fo ruser to choose what to do
        if( user ) { // IS LOGGED IN
            [self processPushNotification:receivedNotification];
        }
        else {
            BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Selbstauskunft" message:@"Eine Push-Nachricht konnte nicht verarbeitet werden. Bitte loggen sie sich zunächst ein."];
            [alert addButtonWithTitle:@"OK" block:nil];
            [alert show];
        }
    }
}

- (void) processPushNotification:(NXPushNotification*)notification {
    NSLog( @"PUSHNOTIFICATION: PROCESSING %@", notification );
    NSURL *urlToOpen = [NSURL URLWithString:notification.actionUrl];
    if( notification.wasReceivedInBackground ) {
        [self openUrlInBridgeView:urlToOpen];
    }
    else {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Selbstauskunft" message:notification.alertMessage];
        [alert addButtonWithTitle:@"Anzeigen" block:^{
            [self openUrlInBridgeView:urlToOpen];
        }];
        [alert setCancelButtonWithTitle:@"Ignorieren" block:nil];
        [alert show];
    }
}
*/

@end
