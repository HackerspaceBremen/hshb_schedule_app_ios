//
//  CalendarViewController.m
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import <QuartzCore/QuartzCore.h>
#import "HSBApplication.h"
#import "CalendarViewController.h"
#import "JTISO8601DateFormatter.h"
#import "SilverDesignView.h"
#import "MOOStyleTrait.h"
#import "MOOMaskedIconView.h"
#import "EventDetailViewController.h"
#import "AppDelegate.h"
#import "DecayAnimation.h"
#import "SettingsViewController.h"

#import "NSObject+JTObjectMapping.h"
#import "HSBAPIClient.h"
#import "HSBStatus.h"
#import "HSBError.h"
#import "HSHBDownloadCalendarEventsOperation.h"

#define kALERT_TAG_CHANGE_SPACE_STATUS  300
#define kALERT_TAG_NO_STATUS_NO_NETWORK 301
#define kALERT_TAG_NO_NETWORK           302
#define kINTERSTITIAL_STEPS 99

@interface CalendarViewController ()

@property (nonatomic, retain) NSOperationQueue *operationQueue;

@end

@implementation CalendarViewController

@synthesize eventsInCalender;
@synthesize selectedRow;
@synthesize segmentedControlMenu;
@synthesize eventListCurrent;
@synthesize eventSectionKeysCurrent;
@synthesize eventListPast;
@synthesize eventSectionKeysPast;
@synthesize cellBackground;
@synthesize cellBackgroundSelected;
@synthesize calendarTimeIntervalSelected;
@synthesize hackerspaceBremenStatus;
@synthesize eventsFavouritedSorted;
@synthesize statusButton;
@synthesize latestHeaderSectionLabel;
@synthesize timerCheckStatus;
@synthesize hasHadInitialSignAnimation;
@synthesize isRefreshingCalendarData;
@synthesize isDisplaysNoStatusNoNetworkAlert;
@synthesize isDisplaysNoNetworkAlert;
@synthesize labelNoFavorites;
@synthesize animatedStar;
@synthesize refreshPopLabel;

- (void) dealloc {
    self.eventsInCalender = nil;
    self.segmentedControlMenu = nil;
    self.eventListCurrent = nil;
    self.eventSectionKeysCurrent = nil;
    self.eventListPast = nil;
    self.eventSectionKeysPast = nil;
    self.cellBackground = nil;
    self.cellBackgroundSelected = nil;
    self.hackerspaceBremenStatus = nil;
    self.statusButton = nil;
    self.eventsFavouritedSorted = nil;
    self.latestHeaderSectionLabel = nil;
    if( timerCheckStatus && [timerCheckStatus isValid] ) {
        [timerCheckStatus invalidate];
    }
    self.timerCheckStatus = nil;
    self.labelNoFavorites = nil;
    self.animatedStar = nil;
    self.refreshPopLabel = nil;
    self.operationQueue = nil;

    [super dealloc];
}

#pragma mark - construction

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - destruction

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - convenience methods

- (AppDelegate*) appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL) isSameDayDate:(NSDate*)date1 asDate:(NSDate*)date2 {
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit );
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsDate1 = [calendar components:units fromDate:date1];
    NSInteger yearDate1 = componentsDate1.year;
    NSInteger monthDate1 = componentsDate1.month;
    NSInteger dayDate1 = componentsDate1.day;
    NSDateComponents *componentsDate2 = [calendar components:units fromDate:date2];
    NSInteger yearDate2 = componentsDate2.year;
    NSInteger monthDate2 = componentsDate2.month;
    NSInteger dayDate2 = componentsDate2.day;
    return( yearDate1 == yearDate2 && monthDate1 == monthDate2 && dayDate1 == dayDate2 );
}

- (NSDate*)dateLastModifiedForFileAtPath:(NSString*)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        if( DEBUG ) NSLog( @"FILE DOES *NOT* EXIST: %@", filePath );
        return nil;
    }
    if( DEBUG ) NSLog( @"FILE EXISTS: %@", filePath );
    NSError *error = nil;
    NSDictionary *itemAttributes = [fm attributesOfItemAtPath:filePath error:&error];
    return [itemAttributes valueForKey:NSFileModificationDate];
}

- (void) displayAlertNoConnection {
    [statusButton setImage:[UIImage imageNamed:@"sign_yellow.png"] forState:UIControlStateNormal];
    [self animateSignWobbleLong];
    self.isRefreshingCalendarData = NO;
    [self.tableView reloadData];
    if( !isDisplaysNoNetworkAlert ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netzverbindung" message:@"Derzeit ist keine Netzverbindung möglich. Bitte prüfe ob eine Internetverbindung besteht und probiere es nocheinmal." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = kALERT_TAG_NO_NETWORK;
        self.isDisplaysNoNetworkAlert = YES;
        [self.refreshControl endRefreshing];
        [alert show];
        [alert release];
    }    
}

- (void)refreshCalendFromInternet {

    self.isRefreshingCalendarData = YES;

    HSHBDownloadCalendarEventsOperation *downloadCalendarEventsOperation = [HSHBDownloadCalendarEventsOperation new];

    NSOperation *saveAndProcessOperation = [NSBlockOperation blockOperationWithBlock:^{

        NSArray *events = downloadCalendarEventsOperation.events;

        if (!events || downloadCalendarEventsOperation.error) {

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                if( DEBUG ) NSLog( @"NO FETCHED DATA TO DISPLAY/PARSE." );

                [self displayAlertNoConnection];

            }];

        } else {

            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:events];

            NSString *pathToStoreFile = [USER_OFFLINEDATA_FOLDER stringByAppendingPathComponent:kOFFLINE_CALENDAR_DATA_FILENAME];
            BOOL hasStoredFile = [data writeToFile:pathToStoreFile atomically:YES];
            if( !hasStoredFile ) {
                if( DEBUG ) NSLog( @"SAVING DATA OFFLINE FAILED!!!" );
            }
            else {
                if( DEBUG ) NSLog( @"SAVED DATA SUCCESSFULLY." );
            }

            [self processEvents:events];


            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                [self updateAfterRefreshUI];

            }];

        }
    }];

    [saveAndProcessOperation addDependency:downloadCalendarEventsOperation];
    [self.operationQueue addOperation:saveAndProcessOperation];

    [self.operationQueue addOperation:downloadCalendarEventsOperation];
    [downloadCalendarEventsOperation release];
}

- (void) updateAfterRefreshUI {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void) refreshCalendarDataFromLocalCachePath:(NSString*)pathToStoredFile {
    if( [[NSFileManager defaultManager] fileExistsAtPath:pathToStoredFile] ) {
        if( DEBUG ) NSLog( @"LOADING FROM LOCAL CACHE..." );
        self.isRefreshingCalendarData = YES;
        NSURL *dataUrl = [NSURL fileURLWithPath:pathToStoredFile];
        NSData* data = [NSData dataWithContentsOfURL:dataUrl];

        NSArray *events = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        [self processEvents:events];
        // UPDATE UI
        [self updateAfterRefreshUI];
    }
    else {
        if( DEBUG ) NSLog( @"NO CACHED DATA AVAILABLE." );
    }    
}

- (void) updateWithStatus:(HSBStatus*)status {
    BOOL needsToAnimate = ( [status.spaceIsOpen boolValue] != [hackerspaceBremenStatus.spaceIsOpen boolValue] );
    self.hackerspaceBremenStatus = status;
    [self appDelegate].hackerspaceBremenStatus = hackerspaceBremenStatus;
    NSString *imageName = [status.spaceIsOpen boolValue] ? @"sign_green.png" : @"sign_red.png";
    [statusButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if( needsToAnimate ) {
        [self animateSignWobbleLong];
    }
    else {
        [self animateSignWobbleShort];
    }
}

- (void) animateSignWobbleLong {
	DecayAnimation *animation = [DecayAnimation animationWithKeyPath:@"transform" start:120.0 end:-2.5 steps:kINTERSTITIAL_STEPS omega:60 zeta:0.20];
	animation.delegate = self;
    animation.duration = 10.0;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
	[statusButton.layer addAnimation:animation forKey:@"wobbleAnimation"];
}

- (void) animateSignWobbleShort {
    [UIView animateWithDuration:0.3 animations:^{
        statusButton.transform = CGAffineTransformMakeRotation( radians(-2.5) );
    }];
}

- (BOOL) hasValidOpenSpaceAccessData {
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    return( uid && [uid length] > 0 && pwd && [pwd length] > 0 );
}

- (void) addSettingsButton {
    // ADD SETTINGS BUTTON
    if( [[UIDevice currentDevice] isOS_7] ) {
        
        NSString *imageName = @"icon_wheel_black.png";
        MOOMaskedIconView *settingsImageView = [MOOMaskedIconView iconWithResourceNamed:imageName];
        settingsImageView.color = kCOLOR_HACKERSPACE_WHITE;
        settingsImageView.userInteractionEnabled = NO;
        
        UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingsButton.frame = CGRectMake(0.0, 0.0, settingsImageView.bounds.size.width+10.0, settingsImageView.bounds.size.height);
        [settingsButton addSubview:settingsImageView];
        settingsImageView.center = settingsButton.center;
        settingsButton.showsTouchWhenHighlighted = YES;
        [settingsButton addTarget:self action:@selector(actionSettings:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *settingsItem = [[[UIBarButtonItem alloc] initWithCustomView:settingsButton] autorelease];
        [self.navigationItem setRightBarButtonItem:settingsItem animated:NO];

        imageName = @"icon_browser.png";
        MOOMaskedIconView *browserImageView = [MOOMaskedIconView iconWithResourceNamed:imageName];
        browserImageView.color = kCOLOR_HACKERSPACE_WHITE;
        browserImageView.userInteractionEnabled = NO;
        
        UIButton *browserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        browserButton.frame = CGRectMake(0.0, 0.0, browserImageView.bounds.size.width+10.0, browserImageView.bounds.size.height);
        [browserButton addSubview:browserImageView];
        browserImageView.center = browserButton.center;
        browserButton.showsTouchWhenHighlighted = YES;
        [browserButton addTarget:self action:@selector(actionDisplayHomepage:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *browserItem = [[[UIBarButtonItem alloc] initWithCustomView:browserButton] autorelease];
        [self.navigationItem setLeftBarButtonItem:browserItem animated:NO];
}
    else {
        UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *settingsButtonImage = [UIImage imageNamed:@"icon_wheel.png"];
        settingsButton.frame = CGRectMake(0.0, 0.0, settingsButtonImage.size.width+20.0, settingsButtonImage.size.height);
        [settingsButton setImage:settingsButtonImage forState:UIControlStateNormal];
        settingsButton.showsTouchWhenHighlighted = YES;
        [settingsButton addTarget:self action:@selector(actionSettings:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *settingsItem = [[[UIBarButtonItem alloc] initWithCustomView:settingsButton] autorelease];
        [self.navigationItem setRightBarButtonItem:settingsItem animated:NO];
    }
}

- (void) refreshCalendarData {
    if( DEBUG ) NSLog( @"CHECKING IF WE NEED NEW CALENDAR UPDATE..." );
    NSString *pathToCacheFile = [USER_OFFLINEDATA_FOLDER stringByAppendingPathComponent:kOFFLINE_CALENDAR_DATA_FILENAME];
    NSDate *lastModified = [self dateLastModifiedForFileAtPath:pathToCacheFile];
    BOOL needsUpdateOfCalendar = YES;
    if( lastModified ) {
        CGFloat ageOfDataInSeconds = MAXFLOAT;
        if( lastModified ) {
            ageOfDataInSeconds = fabsf( [lastModified timeIntervalSinceNow] );
        }
        CGFloat maximumAgeInSeconds = 60.0 * 60.0 * 15.0;
        if( ageOfDataInSeconds > maximumAgeInSeconds ) {
            needsUpdateOfCalendar = YES;
        }
        else {
            needsUpdateOfCalendar = NO;
        }
        if( DEBUG ) NSLog( @"LAST UPDATE IS MORE THAN %.0f SECONDS OLD. UPDATING IN %.0f SECONDS.",ageOfDataInSeconds, (maximumAgeInSeconds -ageOfDataInSeconds) );
    }
    if( ![self appDelegate].hasRefreshedDataAfterStartup || needsUpdateOfCalendar ) {
        if( DEBUG ) NSLog( @"CACHE DATA NEEDS UPDATE..." );
        [self appDelegate].hasRefreshedDataAfterStartup = YES;
        [self refreshCalendFromInternet];
    }
    else {
        if( DEBUG ) NSLog( @"CACHE DATA STILL OKAY." );
        [self refreshCalendarDataFromLocalCachePath:pathToCacheFile];
    }
}

#pragma mark - pop labels -

- (void) setupPopLabels {
    
    [[MMPopLabel appearance] setLabelColor:GREENCOLOR];
    [[MMPopLabel appearance] setLabelTextColor:[UIColor whiteColor]];
    [[MMPopLabel appearance] setLabelTextHighlightColor:[UIColor greenColor]];
    [[MMPopLabel appearance] setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [[MMPopLabel appearance] setButtonFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    
    self.refreshPopLabel = [MMPopLabel popLabelWithText:
                            @"Zieh die Anzeige nach unten, um die Daten zu aktualisieren."];
    
    refreshPopLabel.delegate = self;
    
    //UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectZero];
    //[skipButton setTitle:NSLocalizedString(@"Skip Tutorial", @"Skip Tutorial Button") forState:UIControlStateNormal];
    //[refreshPopLabel addButton:skipButton];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [okButton setTitle:NSLocalizedString(@"OK", @"Dismiss Button") forState:UIControlStateNormal];
    [refreshPopLabel addButton:okButton];
    
    [[self appDelegate].window addSubview:refreshPopLabel];
}

- (IBAction)showPopLabel:(id)sender {
    [refreshPopLabel popAtView:self.tableView.tableHeaderView];
}

- (void)dismissedPopLabel:(MMPopLabel *)popLabel {

}

- (void)didPressButtonForPopLabel:(MMPopLabel *)popLabel atIndex:(NSInteger)index {

}

#pragma mark - API calls to open space

- (void) apiFetchStatusWithBlock:( void (^)( HSBStatus *status, NSError *error ) )block {
    // https://hackerspacehb.appspot.com/v2/status
    
    [[HSBAPIClient sharedClient] getPath:@"status" parameters:nil success:^(AFHTTPRequestOperation *operation, id jsonDataReceived) {
        
        if( DEBUG ) NSLog( @"\n\n*******************************\nJSON RECEIVED: %@\n\n*******************************\n", jsonDataReceived );
        
        HSBStatus *fetchedStatus= [[HSBStatus class] objectFromJSONObject:jsonDataReceived mapping:[[HSBStatus class] objectMapping]];
        
        if( DEBUG ) NSLog( @"\nSTATUS RECEIVED: %@\n", fetchedStatus );
        
        if( block ) {
            block( fetchedStatus, nil ); // RETURN VALUE-SET
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if( block ) {
            block( nil, error ); // RETURN VALUE-SET
        }
    }];
    
}

- (void) apiOpenSpaceWithBlock:( void (^)( HSBStatus *status, NSError *error ) )block {
    // https://hackerspacehb.appspot.com/v2/cmd/open
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    NSString *defaultUserMessage = [NSString stringWithFormat:@"Der Hackerspace ist jetzt geöffnet! (Keykeeper: %@)", userName];
    NSString *userMessage = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_MSG];
    if( !userMessage || [userMessage length] == 0 ) {
        userMessage = defaultUserMessage;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[userName,userPassword,userMessage] forKeys:@[@"name",@"pass",@"message"]];
    [[HSBAPIClient sharedClient] postPath:@"cmd/open" parameters:parameters success:^(AFHTTPRequestOperation *operation, id jsonDataReceived) {
        
        if( DEBUG ) NSLog( @"JSON RECEIVED: %@", jsonDataReceived );
        
        HSBStatus *fetchedStatus= [[HSBStatus class] objectFromJSONObject:jsonDataReceived mapping:[[HSBStatus class] objectMapping]];
        
        if( block ) {
            block( fetchedStatus, nil ); // RETURN VALUE-SET
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if( block ) {
            block( nil, error ); // RETURN VALUE-SET
        }
    }];
    
}

- (void) apiCloseSpaceWithBlock:( void (^)( HSBStatus *status, NSError *error ) )block {
    // https://hackerspacehb.appspot.com/v2/cmd/open
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    NSString *defaultUserMessage = [NSString stringWithFormat:@"Der Hackerspace ist jetzt geschlossen! (Keykeeper: %@)", userName];
    NSString *userMessage = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_MSG];
    if( !userMessage || [userMessage length] == 0 ) {
        userMessage = defaultUserMessage;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:@[userName,userPassword,userMessage] forKeys:@[@"name",@"pass",@"message"]];
    [[HSBAPIClient sharedClient] postPath:@"cmd/close" parameters:parameters success:^(AFHTTPRequestOperation *operation, id jsonDataReceived) {
        
        if( DEBUG ) NSLog( @"JSON RECEIVED: %@", jsonDataReceived );
        
        HSBStatus *fetchedStatus= [[HSBStatus class] objectFromJSONObject:jsonDataReceived mapping:[[HSBStatus class] objectMapping]];
        
        if( block ) {
            block( fetchedStatus, nil ); // RETURN VALUE-SET
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if( block ) {
            block( nil, error ); // RETURN VALUE-SET
        }
    }];
    
}


- (void) apiLoginSpaceWithBlock:( void (^)( HSBStatus *status, NSError *error ) )block {
}


#pragma mark - timer handling

- (void) timerCheckStatusStart {
    if( timerCheckStatus && [timerCheckStatus isValid] ) {
        [timerCheckStatus invalidate];
    }
    self.timerCheckStatus = [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(checkHackerSpaceStatus) userInfo:nil repeats:YES];
    [self checkHackerSpaceStatus];
}

- (void) timerCheckStatusStop {
    if( timerCheckStatus && [timerCheckStatus isValid] ) {
        [timerCheckStatus invalidate];
    }
    self.timerCheckStatus = nil;
}

- (void) checkHackerSpaceStatus {
    if( DEBUG ) NSLog( @"CHECKING STATUS OF HACKERSPACE..." );
    // FETCH REMOTE STATE OF HACKERSPACE
    [self apiFetchStatusWithBlock:^(HSBStatus *status, NSError *error) {
        if( status ) {
            [self updateWithStatus:status];
            // if( DEBUG ) NSLog( @"WE HAVE A STATUS:\n\n%@\n\n", status );
        }
        else {
            if( DEBUG ) NSLog( @"WE HAVE NO STATUS. BUT AN ERROR:\n\n%@\n\n", error );
            if( !isDisplaysNoStatusNoNetworkAlert ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Es konnte nicht ermittelt werden, ob der Hackerspace gerade geöffnet oder geschlossen ist.\n\nUnter Umständen ist die Netzverbindung gestört, oder der Statusserver nicht erreichbar.\n\nProbiere es später noch einmal!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = kALERT_TAG_NO_STATUS_NO_NETWORK;
                self.isDisplaysNoStatusNoNetworkAlert = YES;
                [alert show];
                [alert release];
            }
        }
    }];
}

#pragma mark - view handling

/*
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // [self setNeedsStatusBarAppearanceUpdate];
    self.navigationItem.title = TESTING ? @"Ereignisse (SANDBOX)" : @"Ereignisse";
    // ADD TABLE HEADER
    UIImageView *headerImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableheader.png"]] autorelease];
    headerImageView.contentMode = UIViewContentModeCenter;
    headerImageView.backgroundColor = [UIColor whiteColor];
    headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.tableHeaderView = headerImageView;
    
    // PULL TO REFRESH CONTROL
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = kCOLOR_HACKERSPACE;
    refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Veranstaltungen aktualisieren..."] autorelease];
    [refreshControl addTarget:self action:@selector(actionRefreshPulled:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;


    /*
    // MANUAL REFRESH
    UIBarButtonItem *refreshItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefreshCalendarManually:)] autorelease];
    self.navigationItem.leftBarButtonItem = refreshItem;
    */
    
    [self addSettingsButton];
    
    [self setupPopLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // CONFIGURE TOOLBAR
    if( !segmentedControlMenu ) {
        UIBarButtonItem *spacerItem1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *spacerItem2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        self.segmentedControlMenu = [[[UISegmentedControl alloc] initWithItems:@[@"Aktuell",@"Vergangenheit",@"Favoriten"]] autorelease];
        segmentedControlMenu.selectedSegmentIndex = calendarTimeIntervalSelected;
        [segmentedControlMenu addTarget:self action:@selector(actionSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *segmentItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControlMenu] autorelease];
        NSArray *toolBarItems = @[spacerItem1, segmentItem,spacerItem2];
        [self setToolbarItems:toolBarItems animated:YES];
    }

    if( !statusButton ) {
        self.statusButton = [[[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 186.0, 186.0)] autorelease];
        [statusButton setImage:[UIImage imageNamed:@"sign_red.png"] forState:UIControlStateNormal];
        [statusButton addTarget:self action:@selector(actionDisplayStatusInfo:) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView.tableHeaderView addSubview:statusButton];
        self.tableView.tableHeaderView.userInteractionEnabled = YES;
        statusButton.center = CGPointMake(floorf(self.tableView.tableHeaderView.center.x), floorf(self.tableView.tableHeaderView.center.y-50));

        // INIT WITH CLOSED STATE
        HSBStatus *initStatus = [[[HSBStatus alloc] init] autorelease];
        initStatus.spaceIsOpen = [NSNumber numberWithBool:NO];
        initStatus.spaceName = @"Hackerspace Bremen e.V.";
        initStatus.spaceAddress = @"Bornstraße 14/15, Bremen";
        [self updateWithStatus:initStatus];
    }
    
    
    if( !eventsInCalender || [eventsInCalender count] == 0 ) {
        NSString *pathToCacheFile = [USER_OFFLINEDATA_FOLDER stringByAppendingPathComponent:kOFFLINE_CALENDAR_DATA_FILENAME];
        [self refreshCalendarDataFromLocalCachePath:pathToCacheFile];
    }
    
    [self recompileFavoritedEvents];
    
    // CHECK AT LEAST ALL 15 MINUTES IF THIS VIEW APPEARS
    if( ![self appDelegate].hasRefreshedDataAfterStartup ) {
        [self refreshCalendarData];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkHackerSpaceStatus) name:kNOTIFICATION_APP_GOES_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCalendarData) name:kNOTIFICATION_APP_DATE_TIME_CHANGED object:nil];
    [self timerCheckStatusStart];
    // [self showPopLabel:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self timerCheckStatusStop];
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - custom texts -

- (void) showFloatingTextLabel {
    if( !labelNoFavorites ) {
        self.labelNoFavorites = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, floorf(self.view.bounds.size.height/3.0), self.view.bounds.size.width-20.0, floorf(self.view.bounds.size.height/3.0))] autorelease];
        labelNoFavorites.numberOfLines = 9;
        labelNoFavorites.font = [UIFont boldSystemFontOfSize:24.0];
        labelNoFavorites.textColor = [UIColor lightGrayColor];
        labelNoFavorites.userInteractionEnabled = NO;
        labelNoFavorites.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:labelNoFavorites];
    }
    NSInteger numOfEvents = [self numberOfEventsForTimeInterval:CalendarTimeIntervalCurrent];
    if( numOfEvents > 0 ) {
        labelNoFavorites.text = [NSString stringWithFormat:@"Gibt es keine der\n%li Veranstaltungen,\ndie dir gefällt?", (long)numOfEvents];
    }
    else {
        labelNoFavorites.text = @"Gibt es keine der\nVeranstaltungen,\ndie dir gefällt?";
    }
    labelNoFavorites.alpha = 0.0;
    labelNoFavorites.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        labelNoFavorites.alpha = 1.0;
    } completion:^(BOOL finished) {
        labelNoFavorites.hidden = NO;
        labelNoFavorites.alpha = 1.0;
    }];
}

- (void) hideFloatingTextLabel {
    labelNoFavorites.hidden = YES;
    labelNoFavorites.alpha = 0.0;
}

#pragma mark - user actions

- (IBAction) actionEditFavorites:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    NSUInteger buttonItemType = self.tableView.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    UIBarButtonItem *doneEditItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:buttonItemType target:self action:@selector(actionEditFavorites:)] autorelease];
    [self.navigationItem setRightBarButtonItem:doneEditItem animated:YES];
}

- (IBAction) actionSegmentChanged:(UISegmentedControl*)sender {
    self.calendarTimeIntervalSelected = (CalendarTimeInterval)sender.selectedSegmentIndex;
    if( calendarTimeIntervalSelected == CalendarTimeIntervalFavorites ) {
        [self recompileFavoritedEvents];
        if( [eventsFavouritedSorted count] > 0 ) {
            [self hideFloatingTextLabel];
            NSUInteger buttonItemType = self.tableView.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
            UIBarButtonItem *doneEditItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:buttonItemType target:self action:@selector(actionEditFavorites:)] autorelease];
            [self.navigationItem setRightBarButtonItem:doneEditItem animated:YES];
        }
        else {
            [self showFloatingTextLabel];
        }
    }
    else {
        [self hideFloatingTextLabel];
        [self.tableView setEditing:NO animated:NO];
        [self addSettingsButton];
    }
    [self.tableView reloadData];
}

- (IBAction) actionRefreshPulled:(id)sender {
    [self.refreshControl beginRefreshing];
    [self refreshCalendFromInternet];
}

- (IBAction) actionDisplayStatusInfo:(UIBarButtonItem*)sender {
    NSString *stateString = [hackerspaceBremenStatus.spaceIsOpen boolValue] ? @"geöffnet" : @"geschlossen";
    NSString *doorActionString = [hackerspaceBremenStatus.spaceIsOpen boolValue] ? @"Schließen" : @"Öffnen";
    NSString *actionString = [hackerspaceBremenStatus.spaceIsOpen boolValue] ? @"schließen" : @"öffnen";
    BOOL canManageSpace = [self hasValidOpenSpaceAccessData];
    
    // ADD DATE/TIME TO STATE STRING
    if( [hackerspaceBremenStatus dateOfLastChangeStatus] ) {
        NSString *niceFormattedDate = [NSString stringWithFormat:@"%@", [hackerspaceBremenStatus dateOfLastChangeStatus]];
        @try {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.doesRelativeDateFormatting = YES;
            // df.timeZone = [[[NSTimeZone alloc] initWithName:@"GMT+2"] autorelease];
            df.timeStyle = NSDateFormatterMediumStyle;
            df.dateStyle = NSDateFormatterLongStyle;
            niceFormattedDate = [df stringFromDate:[hackerspaceBremenStatus dateOfLastChangeStatus]];
            [df release];
        }
        @catch (NSException *exception) {
            //
        }
        stateString = [NSString stringWithFormat:@"%@ seit %@ (in deiner lokalen Zeit)", stateString, niceFormattedDate];
    }
    
    UIAlertView *alert = nil;
    NSString *messageString = nil;
    NSString *spaceStateReason = nil;
    if( hackerspaceBremenStatus.spaceStatusMessage && [hackerspaceBremenStatus.spaceStatusMessage length] > 0 ) {
        spaceStateReason = [NSString stringWithFormat:@"\n\nGruß an Besucher:\n%@",hackerspaceBremenStatus.spaceStatusMessage];
    }
    else {
        spaceStateReason = @"";
    }
    NSMutableString *contactString = [NSMutableString string];
    if( hackerspaceBremenStatus.spaceContact ) {
        if( hackerspaceBremenStatus.spaceContact.phone && [hackerspaceBremenStatus.spaceContact.phone length] > 0 ) {
            [contactString appendFormat:@"\n\nTelefon: %@", hackerspaceBremenStatus.spaceContact.phone];
        }
        if( hackerspaceBremenStatus.spaceContact.email && [hackerspaceBremenStatus.spaceContact.email length] > 0 ) {
            [contactString appendFormat:@"\nE-Mail: %@", hackerspaceBremenStatus.spaceContact.email];
        }
        if( hackerspaceBremenStatus.spaceContact.twitter && [hackerspaceBremenStatus.spaceContact.twitter length] > 0 ) {
            [contactString appendFormat:@"\nTwitter: %@", hackerspaceBremenStatus.spaceContact.twitter];
        }
    }
    if( canManageSpace ) {
        messageString = [NSString stringWithFormat:@"Der %@, %@ ist jetzt %@.%@%@\n\nDu bist Keykeeper und möchtest den Space %@, dann tippe auf '%@'.", hackerspaceBremenStatus.spaceName, hackerspaceBremenStatus.spaceAddress, stateString, spaceStateReason, contactString,actionString,doorActionString];
        alert = [[UIAlertView alloc] initWithTitle:@"Information" message:messageString delegate:self cancelButtonTitle:doorActionString otherButtonTitles:@"OK", nil];
    }
    else {
        messageString = [NSString stringWithFormat:@"Der %@, %@ ist jetzt %@.%@%@", hackerspaceBremenStatus.spaceName, hackerspaceBremenStatus.spaceAddress, stateString, spaceStateReason, contactString];
        alert = [[UIAlertView alloc] initWithTitle:@"Information" message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    }
    alert.tag = kALERT_TAG_CHANGE_SPACE_STATUS;
    [alert show];
    [alert release];
}

- (IBAction) actionRefreshCalendarManually:(id)sender {
    [self refreshCalendFromInternet];
}

- (IBAction) actionFavoriteEvent:(UIButton*)favButton {
    self.selectedRow = favButton.tag;
    UIView *favStarImageView = [favButton.subviews lastObject];
    NSInteger section = favStarImageView.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:section];
    GoogleCalendarEvent *event = [self eventAtIndexPath:indexPath];
    if( [event isMarkedAsFavorite] ) {
        [[self appDelegate] removeFromFavoritesEvent:event];
    }
    else {
        [[self appDelegate] addToFavoritesEvent:event];
        [self displayAddStarAnimationToPoint:favButton.center];
    }
    [self recompileFavoritedEvents];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction) actionSettings:(id)sender {
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (IBAction)actionDisplayHomepage:(id)sender {
    HSBApplication *app = (HSBApplication*)[UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:@"http://www.hackerspace-bremen.de"]];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch( alertView.tag ) {
        case kALERT_TAG_NO_STATUS_NO_NETWORK: {
            self.isDisplaysNoStatusNoNetworkAlert = NO;
            break;
        }

        case kALERT_TAG_NO_NETWORK: {
            self.isDisplaysNoNetworkAlert = NO;
            break;
        }

        case kALERT_TAG_CHANGE_SPACE_STATUS: {
            if( buttonIndex == alertView.cancelButtonIndex ) { // LOGIN
                if( [hackerspaceBremenStatus.spaceIsOpen boolValue] ) {
                    if( DEBUG ) NSLog( @"TRYING TO CLOSE SPACE..." );
                    [self apiCloseSpaceWithBlock:^(HSBStatus *status, NSError *error) {
                        if( error ) {
                            NSError *jsonParsingError = nil;
                            NSData *jsonAsData = [[error localizedRecoverySuggestion] dataUsingEncoding:NSUTF8StringEncoding];
                            id jsonError = [NSJSONSerialization JSONObjectWithData:jsonAsData options:NSJSONReadingAllowFragments error:&jsonParsingError];
                            HSBError *fetchedError= [[HSBError class] objectFromJSONObject:jsonError mapping:[[HSBError class] objectMapping]];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *message = [NSString stringWithFormat:@"Der Server antwortete Fehlercode: %li\n%@",(long)[fetchedError.errorCode integerValue], fetchedError.errorMessage];

                                AMSmoothAlertView *alert = nil;
                                alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Problem" andText:message andCancelButton:NO forAlertType:AlertFailure];
                                alert.delegate = nil;
                                [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
                                [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
                                alert.cornerRadius = 3.0f;
                                [alert show];
                                [alert release];
                            });
                        }
                        else {
                            [self checkHackerSpaceStatus];
                        }
                        if( DEBUG ) NSLog( @"NEW STATUS IS: %@ (ERROR: %@)", [status.spaceIsOpen boolValue] ? @"OPEN" : @"CLOSED", error );
                        
                    }];
                }
                else {
                    if( DEBUG ) NSLog( @"TRYING TO OPEN SPACE..." );
                    [self apiOpenSpaceWithBlock:^(HSBStatus *status, NSError *error) {
                        if( error ) {
                            NSError *jsonParsingError = nil;
                            NSData *jsonAsData = [[error localizedRecoverySuggestion] dataUsingEncoding:NSUTF8StringEncoding];
                            id jsonError = [NSJSONSerialization JSONObjectWithData:jsonAsData options:NSJSONReadingAllowFragments error:&jsonParsingError];
                            HSBError *fetchedError= [[HSBError class] objectFromJSONObject:jsonError mapping:[[HSBError class] objectMapping]];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *message = [NSString stringWithFormat:@"Der Server antwortete Fehlercode: %li\n%@",(long)[fetchedError.errorCode integerValue], fetchedError.errorMessage];
                                
                                AMSmoothAlertView *alert = nil;
                                alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Problem" andText:message andCancelButton:NO forAlertType:AlertFailure];
                                alert.delegate = nil;
                                [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
                                [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
                                alert.cornerRadius = 3.0f;
                                [alert show];
                                [alert release];
                            });
                        }
                        else {
                            [self checkHackerSpaceStatus];
                        }
                        if( DEBUG ) NSLog( @"NEW STATUS IS: %@ (ERROR: %@)", [status.spaceIsOpen boolValue] ? @"OPEN" : @"CLOSED", error );
                    }];
                }
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch( actionSheet.tag ) {
            
        case 200: { // add event
            if( buttonIndex == actionSheet.firstOtherButtonIndex ) {
                [self addEventToCalendarAtSelectedRow:selectedRow];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void) addEventToCalendarAtSelectedRow:(NSInteger)rowIndex {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    GoogleCalendarEvent *calEvent = [eventsInCalender objectAtIndex:rowIndex];
    if( calEvent ) {
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = calEvent.Title;
        event.startDate = calEvent.StartDate;
        event.endDate   = calEvent.EndDate;
        [event setNotes:calEvent.Description];
        //event.description = calEvent.description;
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    }
    [eventStore release];
}

- (NSInteger) numberOfEventsForTimeInterval:(CalendarTimeInterval)interval {
    NSInteger eventCount = 0;
    switch( interval ) {
        case CalendarTimeIntervalCurrent:
            for( NSArray *itemList in [eventListCurrent allValues] ) {
                eventCount += [itemList count];
            }
            break;
            
        case CalendarTimeIntervalPast:
            for( NSArray *itemList in [eventListPast allValues] ) {
                eventCount += [itemList count];
            }
            break;
            
        case CalendarTimeIntervalFavorites:
                eventCount += [eventsFavouritedSorted count];
            break;
            
        default:
            break;
    }
    return eventCount;
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if( !eventsInCalender || [eventsInCalender count] == 0 ) {
        return 1;
    }

    NSInteger numOfSections = 0;
    switch( segmentedControlMenu.selectedSegmentIndex ) {

        case 0: {
            numOfSections = [eventSectionKeysCurrent count];
            break;
        }
            
        case 1: {
            numOfSections = [eventSectionKeysPast count];
            break;
        }
            
        case 2:
            numOfSections = 1;
            break;
            
        default:
            numOfSections = 0;
            break;
    }
    if( numOfSections == 0 ) {
        numOfSections = 1;
    }
    return numOfSections;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if( !eventsInCalender || [eventsInCalender count] == 0 ) {
        return 1;
    }
    
    NSInteger numOfRows = 0;
    switch( segmentedControlMenu.selectedSegmentIndex ) {
            
        case 0: {
            if( eventSectionKeysCurrent && [eventSectionKeysCurrent count] > 0 ) {
                NSArray *itemsInSection = [eventListCurrent objectForKey:[eventSectionKeysCurrent objectAtIndex:section]];
                numOfRows = [itemsInSection count];
            }
            break;
        }
            
        case 1: {
            if( eventSectionKeysPast && [eventSectionKeysPast count] > 0 ) {
                NSArray *itemsInSection = [eventListPast objectForKey:[eventSectionKeysPast objectAtIndex:section]];
                numOfRows = [itemsInSection count];
            }
            break;
        }
            
        case 2: {
            numOfRows = [eventsFavouritedSorted count];
            break;
        }
            
        default:
            numOfRows = 0;
            break;
    }
    if( numOfRows == 0 && calendarTimeIntervalSelected != CalendarTimeIntervalFavorites ) {
        return numOfRows = 1;
    }
    return numOfRows;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if( !eventsInCalender || [eventsInCalender count] == 0 ) {
        return @"Lade Veranstaltungsdaten...";
    }
    switch( segmentedControlMenu.selectedSegmentIndex ) {
        
        case 0: {
            if( !eventSectionKeysCurrent || [eventSectionKeysCurrent count] == 0 ) {
                return @"Keine Veranstaltungen";
            }
            else {
                return [eventSectionKeysCurrent objectAtIndex:section];
            }
            break;
        }
            
        case 1: {
            if( !eventSectionKeysPast || [eventSectionKeysPast count] == 0 ) {
                return @"Keine Veranstaltungen";
            }
            else {
                return [eventSectionKeysPast objectAtIndex:section];
            }
            break;
        }

        case 2: {
            if( !eventsFavouritedSorted || [eventsFavouritedSorted count] == 0 ) {
                return @"Keine Favoriten";
            }
            else {
                return [NSString stringWithFormat:@"%lu Favoriten", (unsigned long)[eventsFavouritedSorted count]];
            }
            break;
        }

        default:
            return 0;
            break;
    }
}

- (GoogleCalendarEvent*)eventAtIndexPath:(NSIndexPath*)indexPath {
    GoogleCalendarEvent *currentGoogleEvent = nil;
    switch( segmentedControlMenu.selectedSegmentIndex ) {
            
        case 0: {
            if( eventSectionKeysCurrent && [eventSectionKeysCurrent count] > 0 && (indexPath.section <= [eventSectionKeysCurrent count]-1) ) {
                NSArray *itemsInSection = [eventListCurrent objectForKey:[eventSectionKeysCurrent objectAtIndex:indexPath.section]];
                if( itemsInSection && (indexPath.row <= [itemsInSection count]-1) ) {
                    currentGoogleEvent = [itemsInSection objectAtIndex:indexPath.row];
                }
            }
            break;
        }
            
        case 1: {
            
            if( eventSectionKeysPast && [eventSectionKeysPast count] > 0 && (indexPath.section <= [eventSectionKeysPast count]-1) ) {
                NSArray *itemsInSection = [eventListPast objectForKey:[eventSectionKeysPast objectAtIndex:indexPath.section]];
                if( itemsInSection && [itemsInSection count] > 0 && (indexPath.row <= [itemsInSection count]-1) ) {
                    currentGoogleEvent = [itemsInSection objectAtIndex:indexPath.row];
                }
            }
            break;
        }
            
        case 2: {
            if( eventsFavouritedSorted && [eventsFavouritedSorted count] > 0 && indexPath.row <= ([eventsFavouritedSorted count]-1) ) {
                currentGoogleEvent = [eventsFavouritedSorted objectAtIndex:indexPath.row];
            }
            break;
        }
            
        default:
            return nil;
            break;
    }
    return currentGoogleEvent;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.numberOfLines = 3;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryView = nil;
    cell.textLabel.textColor = [UIColor blackColor];

    // BACKGROUND
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    UIColor *cellBackColor = (indexPath.row % 2 == 0) ? [UIColor whiteColor] : [UIColor colorWithRGBHex:0xf0f0f0];

    self.cellBackground = [[[SilverDesignView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, cellHeight)] autorelease];
    if( [UIDevice currentDevice].versionAsInteger < 7 ) {
        cellBackground.colorTop = [UIColor colorWithHexString:@"FFFFFF"];
        cellBackground.colorBottom = [UIColor colorWithHexString:@"F9F9F9"];
        cellBackground.colorLineBright = [UIColor whiteColor];
        cellBackground.colorLineDark = [[UIColor darkGrayColor] colorByLighteningTo:0.5];
    }
    else {
        cellBackground.colorTop = cellBackColor;
        cellBackground.colorBottom = cellBackColor;
        cellBackground.colorLineBright = cellBackColor;
        cellBackground.colorLineDark = cellBackColor;
    }
    cellBackground.backgroundColor = [UIColor clearColor];
    cellBackground.useFancyGradient = NO;
    cellBackground.autoresizesSubviews = YES;
    cellBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cellBackground.contentMode = UIViewContentModeRedraw;
    
    // BACKGROUND SELECTED
    self.cellBackgroundSelected = [[[SilverDesignView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, cellHeight)] autorelease];
    if( [UIDevice currentDevice].versionAsInteger < 7 ) {
        cellBackgroundSelected.colorTop = [UIColor colorWithHexString:@"CCCCCC"];
        cellBackgroundSelected.colorBottom = [UIColor colorWithHexString:@"AAAAAA"];
        cellBackgroundSelected.colorLineBright = [UIColor whiteColor];
        cellBackgroundSelected.colorLineDark = [[UIColor darkGrayColor] colorByLighteningTo:0.5];
    }
    else {
        cellBackground.colorTop = cellBackColor;
        cellBackground.colorBottom = cellBackColor;
        cellBackground.colorLineBright = cellBackColor;
        cellBackground.colorLineDark = cellBackColor;
    }
    cellBackgroundSelected.backgroundColor = [UIColor clearColor];
    cellBackgroundSelected.useFancyGradient = NO;
    cellBackgroundSelected.autoresizesSubviews = YES;
    cellBackgroundSelected.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cellBackgroundSelected.contentMode = UIViewContentModeRedraw;


    cell.backgroundView = cellBackground;
    cell.selectedBackgroundView  = cellBackgroundSelected;

    // IF NO DATA RETURN EMPTY CELL
    if( !eventsInCalender || [eventsInCalender count] == 0 ) {
        cell.textLabel.text = @"Veranstaltungsdaten des Hackerspace";
        if( isRefreshingCalendarData ) {
            cell.detailTextLabel.text = @"Daten des Veranstaltungsprogramms werden heruntergeladen. Dies kann einen Moment dauern...";
            UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            [spinner startAnimating];
            cell.accessoryView = spinner;
        }
        else {
            cell.detailTextLabel.text = @"Bitte hier antippen, um das Herunterladen des Veranstaltungsprogramms erneut zu versuchen.";            
        }
        return cell;
    }

    if( ![self eventAtIndexPath:indexPath] ) {
        if( calendarTimeIntervalSelected == CalendarTimeIntervalFavorites ) {
            cell.textLabel.text = @"Keine Favoriten vorgemerkt";
            cell.detailTextLabel.text = @"Markiere in den aktuellen Veranstaltungen deinen Favoriten mit einem Stern.";
        }
        else {
            cell.textLabel.text = @"Keine Veranstaltungsinformation";
            cell.detailTextLabel.text = @"Es liegen leider keine Informationen für den gewählten Bereich vor. Versuche die Information zu aktualisieren.";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    // CONFIGURE DISPLAY DATA
    GoogleCalendarEvent *currentGoogleEvent = [self eventAtIndexPath:indexPath];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [df setLocale:locale];
    [df setDateStyle:NSDateFormatterMediumStyle];
    df.doesRelativeDateFormatting = YES;
    
    NSString *startDateStr = [df stringFromDate:currentGoogleEvent.StartDate];
    
    BOOL isToday = [self isSameDayDate:[NSDate date] asDate:currentGoogleEvent.StartDate];
    cell.textLabel.textColor = isToday ? kCOLOR_HACKERSPACE : [UIColor blackColor];
    
    
    [df setDateFormat:@"H:mm"];

    NSString *hoursOpen = [NSString stringWithFormat:@"%@, %@ bis %@ Uhr", startDateStr, [df stringFromDate:currentGoogleEvent.StartDate], [df stringFromDate:currentGoogleEvent.EndDate]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", currentGoogleEvent.Title ];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@", hoursOpen, currentGoogleEvent.Description];
    
    
    // NOT PERFORMING TOO WELL
    /*
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
    NSDictionary *hourAttributes = [NSDictionary dictionaryWithObject:kCOLOR_HACKERSPACE forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *hoursString = [[NSAttributedString alloc] initWithString:hoursOpen attributes:hourAttributes];
    [string appendAttributedString:hoursString];
    [hoursString release];

    
    NSDictionary *descriptionAttributes = [NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    
    NSString *descriptionText = [NSString stringWithFormat:@"%@", currentGoogleEvent.Description];
    NSAttributedString *descriptionString = [[NSAttributedString alloc] initWithString:descriptionText attributes:descriptionAttributes];
    [string appendAttributedString:descriptionString];
    [descriptionString release];

    cell.detailTextLabel.attributedText = string;
     [string release];
     */
    
    // STYLE ICON
    MOOStyleTrait *grayIconTrait = [MOOStyleTrait trait];
    
    grayIconTrait.gradientColors = [NSArray arrayWithObjects:
                                    [UIColor colorWithHue:0.0f saturation:0.05f brightness:0.34f alpha:1.0f],
                                    [UIColor colorWithHue:0.0f saturation:0.05f brightness:0.57f alpha:1.0f], nil];
    grayIconTrait.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    grayIconTrait.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    grayIconTrait.innerShadowColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    grayIconTrait.innerShadowOffset = CGSizeMake(0.0f, -1.0f);

    NSString *imageName = currentGoogleEvent.isMarkedAsFavorite ? @"icon_favstar_filled.png" : @"icon_favstar_framed.png";
    MOOMaskedIconView *calendarIconView = [MOOMaskedIconView iconWithResourceNamed:imageName];
    calendarIconView.color = currentGoogleEvent.isMarkedAsFavorite ? kCOLOR_HACKERSPACE : [UIColor lightGrayColor];
    //[calendarIconView mixInTrait:grayIconTrait];
    calendarIconView.userInteractionEnabled = NO;
    
    
    if( isToday || segmentedControlMenu.selectedSegmentIndex == 1 || segmentedControlMenu.selectedSegmentIndex == 2 ) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        UIButton *button = [UIButton  buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 0.0, 40, 40);
        button.showsTouchWhenHighlighted = YES;
        [button addTarget:self action:@selector(actionFavoriteEvent:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:calendarIconView];
        calendarIconView.center = button.center;
        // [button setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
        // [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        calendarIconView.tag = [indexPath section];
        button.tag = [indexPath row];
        cell.accessoryView = button;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    [df release], df = nil;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height50 = 30.0f;
    CGFloat height20 = 19.0f;
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, height50)] autorelease];
    CGFloat offset = 0.0;
    
    UIView *someView = nil;
    if( [UIDevice currentDevice].versionAsInteger < 7 ) {
        SilverDesignView *silverView = [[[SilverDesignView alloc] initWithFrame:CGRectMake(offset, 0.0, self.view.bounds.size.width-(2.0*offset), height50)] autorelease];
        [containerView addSubview:silverView];
        silverView.colorTop = kCOLOR_HACKERSPACE;
        silverView.colorBottom = kCOLOR_HACKERSPACE_VERY_DARK;
        silverView.colorLineBright = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        silverView.colorLineDark = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        silverView.backgroundColor = [UIColor clearColor];
        silverView.useFancyGradient = NO;
        silverView.autoresizesSubviews = YES;
        silverView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        silverView.hasRoundCornersTop = NO;
        someView = silverView;
    }
    else {
        someView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, height50)] autorelease];
        [containerView addSubview:someView];
        someView.backgroundColor = kCOLOR_HACKERSPACE;
        someView.opaque = YES;
    }
    CGFloat inset = 10.0f;
    self.latestHeaderSectionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(inset, 0.0, someView.bounds.size.width-(2.0*inset), height50)] autorelease];
    [someView addSubview:latestHeaderSectionLabel];
    latestHeaderSectionLabel.backgroundColor = [UIColor clearColor];
    latestHeaderSectionLabel.font = [UIFont boldSystemFontOfSize:height20];
    if( [[UIDevice currentDevice] versionAsInteger] < 7 ) {
        latestHeaderSectionLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        latestHeaderSectionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    latestHeaderSectionLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    latestHeaderSectionLabel.adjustsFontSizeToFitWidth = YES;
    
    // GET SECTION TITLE
    latestHeaderSectionLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return containerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TRIGER NEW FETCH
    if( !eventsInCalender || [eventsInCalender count] == 0 ) {
        self.isRefreshingCalendarData = YES;
        [self.tableView reloadData];
        [self refreshCalendarData];
        return;
    }
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Zurück" style:UIBarButtonItemStyleDone target:nil action:nil] autorelease];
    GoogleCalendarEvent *event = [self eventAtIndexPath:indexPath];
    if( event ) {
        EventDetailViewController *detailViewController = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
        detailViewController.eventToDisplay = event;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UITableView editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( calendarTimeIntervalSelected == CalendarTimeIntervalFavorites ) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if( DEBUG ) NSLog( @"%s", __PRETTY_FUNCTION__  );
}

- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // if( DEBUG ) NSLog( @"%s", __PRETTY_FUNCTION__  );
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // if( DEBUG ) NSLog( @"%s", __PRETTY_FUNCTION__  );
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( DEBUG ) NSLog( @"%s", __PRETTY_FUNCTION__  );
    GoogleCalendarEvent *eventToDelete = [self eventAtIndexPath:indexPath];
    if( eventToDelete ) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [eventsFavouritedSorted removeObject:eventToDelete];
        [tableView endUpdates];
        [[self appDelegate] removeFromFavoritesEvent:eventToDelete];
        // UPDATE HEADER TITLE
        latestHeaderSectionLabel.text = [self tableView:tableView titleForHeaderInSection:0];
        if( [eventsFavouritedSorted count] == 0 ) {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
            [self.tableView setEditing:NO animated:NO];
            [self showFloatingTextLabel];
            [self recompileFavoritedEvents];
        }
        else {
            [self hideFloatingTextLabel];
        }
    }
    else {

    }
}

 - (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
 return @"Entfernen";
 }

- (void) tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // if( DEBUG ) NSLog( @"%s", __PRETTY_FUNCTION__  );
}

#pragma mark - parse google calendar & prepare data sources

- (void) recompileFavoritedEvents {
    self.eventsFavouritedSorted = [NSMutableArray array];
    for( NSString *currentSectionKey in eventSectionKeysCurrent ) {
        NSArray *currentRows = [eventListCurrent objectForKey:currentSectionKey];
        for( GoogleCalendarEvent *currentEvent in currentRows ) {
            if( currentEvent.isMarkedAsFavorite ) {
                [eventsFavouritedSorted addObject:currentEvent];
            }
        }
    }
    if( DEBUG ) NSLog( @"WE HAVE RECOMPILED %lu FAVORITES.", (unsigned long)[eventsFavouritedSorted count] );
    NSUInteger numOfFavorites = (unsigned int)[eventsFavouritedSorted count];
    NSString *favoritesTitle = @"Favoriten";
    if( [eventsFavouritedSorted count] > 0 ) {
        if( [eventsFavouritedSorted count] == 1 ) {
            favoritesTitle = [NSString stringWithFormat:@"%lu Favorit", (unsigned long)numOfFavorites];
        }
        else {
            favoritesTitle = [NSString stringWithFormat:@"%lu Favoriten", (unsigned long)numOfFavorites];
        }
    }
    [segmentedControlMenu setTitle:favoritesTitle forSegmentAtIndex:[segmentedControlMenu numberOfSegments]-1]; // last item
}

- (void)processEvents:(NSArray *)events
{
    if(!events) return;
    
    self.eventsInCalender = [NSMutableArray array];
    
    for (GoogleCalendarEvent *event in events) {

        event.isMarkedAsFavorite = [self appDelegate].storedFavoriteEvents[event.uniqueId] != nil;

        [self.eventsInCalender addObject:event];

    }

    // CREATE DATASTRUCTURE FOR CURRENT SET
    self.eventListCurrent = [NSMutableDictionary dictionary];
    self.eventSectionKeysCurrent = [NSMutableArray array];
    self.eventListPast = [NSMutableDictionary dictionary];
    self.eventSectionKeysPast = [NSMutableArray array];

    // STEP 1: alles in MONATSNAME JAHRESZAHL sections
    // STEP 2: component des Jahres und monats ermitteln und einfach durchzählen
    
    NSUInteger units = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit );
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *componentsNow = [calendar components:units fromDate:nowDate];
    NSInteger yearNow = componentsNow.year;
    NSInteger monthNow = componentsNow.month;
    NSInteger dayNow = componentsNow.day;
    NSDateComponents *componentsCurrent;
    NSString *sectionKey = nil;
    NSArray *monthNames = @[@"Januar",@"Februar",@"März",@"April",@"Mai",@"Juni",@"Juli",@"August",@"September",@"Oktober",@"November",@"Dezember"];
    
    for( GoogleCalendarEvent *currentGoogleEvent in eventsInCalender ) {
        componentsCurrent = [calendar components:units fromDate:currentGoogleEvent.StartDate];
        NSInteger yearCurrent = componentsCurrent.year;
        NSInteger monthCurrent = componentsCurrent.month;
        NSInteger dayCurrent = componentsCurrent.day;
        
        sectionKey = [NSString stringWithFormat:@"%@ %li", [monthNames objectAtIndex:(monthCurrent-1)], (long)yearCurrent];

        BOOL shouldAddToOld = NO;
        
        if( yearCurrent <= yearNow ) {
            if( yearCurrent == yearNow ) { // 2013 == 2013
                if( monthCurrent == monthNow ) { // 9 == 9
                    if( dayCurrent < dayNow ) { // 3 < 11
                        // OLD
                        shouldAddToOld = YES;
                    }
                    else { // 11 >= 11
                        // CURRENT/FUTURE
                        shouldAddToOld = NO;
                    }
                }
                else if( monthCurrent < monthNow ) { // 5 < 9
                    // OLD
                    shouldAddToOld = YES;
                }
                else { // 12 > 9
                    // CURRENT/FUTURE
                    shouldAddToOld = NO;
                }
            }
            else if( yearCurrent < yearNow ) {
                // OLD
                shouldAddToOld = YES;
            }
        }
        else { // 2014 > 2013
            // CURRENT/FUTURE
            shouldAddToOld = NO;
        }
    
        // ADD TODAY AS SECTION KEY
        if( yearCurrent == yearNow &&  monthCurrent == monthNow && dayCurrent == dayNow ) { // TODAY
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.timeStyle = NSDateFormatterNoStyle;
            df.dateStyle = NSDateFormatterFullStyle;
            NSString *dateString = [df stringFromDate:nowDate];
            sectionKey = [NSString stringWithFormat:@"Heute, %@", dateString];
            [df release];
        }
        
        // DO THE ACTUAL WORK OF SORTING IN STUFF
        if( shouldAddToOld ) {
            NSMutableArray *registeredArray = [eventListPast objectForKey:sectionKey];
            if( !registeredArray ) {
                registeredArray = [NSMutableArray array];
                [eventListPast setObject:registeredArray forKey:sectionKey];
                [eventSectionKeysPast addObject:sectionKey];
            }
            [registeredArray addObject:currentGoogleEvent];
        }
        else {
            NSMutableArray *registeredArray = [eventListCurrent objectForKey:sectionKey];
            if( !registeredArray ) {
                registeredArray = [NSMutableArray array];
                [eventListCurrent setObject:registeredArray forKey:sectionKey];
                [eventSectionKeysCurrent addObject:sectionKey];
            }
            [registeredArray addObject:currentGoogleEvent];
        }
    }
    
    // REVERT SORTING OF OLD CRAP
    NSMutableArray *eventSectionKeysPastCloned = [[eventSectionKeysPast copy] autorelease];
    self.eventSectionKeysPast = [NSMutableArray array];
    for( NSInteger index = [eventSectionKeysPastCloned count]-1; index > 0; index-- ) {
        NSString *currentSectionKey = [eventSectionKeysPastCloned objectAtIndex:index];
        [eventSectionKeysPast addObject:currentSectionKey];
        
        // REVERT EACH SECTIONS ROWS
        NSMutableArray *currentSectionRows = [eventListPast objectForKey:currentSectionKey];
        NSMutableArray *currentSectionRowsCloned = [[currentSectionRows copy] autorelease];
        currentSectionRows = [NSMutableArray array];
        for( NSInteger rowIndex = [currentSectionRowsCloned count]-1; rowIndex > 0; rowIndex-- ) {
            [currentSectionRows addObject:[currentSectionRowsCloned objectAtIndex:rowIndex]];
        }
        [eventListPast setObject:currentSectionRows forKey:currentSectionKey];
    }
    
    [self recompileFavoritedEvents];
    self.isRefreshingCalendarData = NO;
}

#pragma mark - star animation -

CGAffineTransform oldTransform;
float durationPartAnimation = 0.125;
float durationFullAnimation = 0.5;
CGPoint rightMapNormalPosition;
CGPoint leftMapNormalPosition;


- (CGPoint) pointForSelectedMapEntryInMasterView {
    CGPoint pointFound = self.view.center;
    return pointFound;
}


-(void) addAnimationPathToLayer:(CALayer*)layerToModify fromPoint:(CGPoint)startPointAnimation {
    /*
    CGPoint startPoint = CGPointMake(startPointAnimation.x, startPointAnimation.y); // CGPointMake(700, 950);
    CGPoint controlPoint1 = CGPointMake(30, -30);
    CGPoint controlPoint2 = CGPointMake(90, -90);
    CGPoint endPoint = segmentedControlMenu.center;
     */

    CGPoint startPoint = CGPointMake(250, 256);
    CGPoint controlPoint1 = CGPointMake(30, -30);
    CGPoint controlPoint2 = CGPointMake(90, -90);
    CGPoint endPoint = CGPointMake(270, 120);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(path, NULL,
                          controlPoint1.x, controlPoint1.y,
                          controlPoint2.x, controlPoint2.y,
						  endPoint.x, endPoint.y);
	
    CAKeyframeAnimation *keyFrameAnimation =
    [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [keyFrameAnimation setDuration:durationFullAnimation];
    [keyFrameAnimation setPath:path];
	
	CAMediaTimingFunction* accelerated = [CAMediaTimingFunction functionWithControlPoints:0.7 : 0.2 :0.9 :0.95];
    [keyFrameAnimation setTimingFunction:accelerated];
    
    [layerToModify addAnimation:keyFrameAnimation forKey:@"FLYINGSTAR"];
    [layerToModify setPosition:endPoint];
    CFRelease(path);
}


- (void) animateViewPart1:(UIView*)viewToAnim {
	oldTransform = [viewToAnim transform];
	CGAffineTransform rotate1 = CGAffineTransformMakeRotation( 2 * M_PI * 0.25);
	rotate1 = CGAffineTransformScale( rotate1, 2.0, 2.0 );
	CGAffineTransform effect1 = CGAffineTransformConcat( oldTransform, rotate1 );
	
	[UIView beginAnimations:@"myAnimationPart1" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(didStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:durationPartAnimation];
	[UIView setAnimationRepeatCount:1];
	[viewToAnim setTransform:effect1];
	[UIView commitAnimations];
}

- (void) animateViewPart2:(UIView*)viewToAnim {
	CGAffineTransform rotate2 = CGAffineTransformMakeRotation( 2 * M_PI * 0.25);
	// CGAffineTransform rotate2 = CGAffineTransformMakeRotation( 90 * M_PI / 180);
	rotate2 = CGAffineTransformScale( rotate2, 2.0, 2.0 );
	CGAffineTransform effect2 = CGAffineTransformConcat( [viewToAnim transform], rotate2 );
	
	[UIView beginAnimations:@"myAnimationPart2" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(didStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:durationPartAnimation];
	[UIView setAnimationRepeatCount:1];
	[viewToAnim setTransform:effect2]; // apply effect
	[UIView commitAnimations];
}


- (void) animateViewPart3:(UIView*)viewToAnim {
	CGAffineTransform rotate3 = CGAffineTransformMakeRotation( 2 * M_PI * 0.25);
	rotate3 = CGAffineTransformScale( rotate3, 0.5, 0.5 );
	CGAffineTransform effect3 = CGAffineTransformConcat( [viewToAnim transform], rotate3 );
	
	[UIView beginAnimations:@"myAnimationPart3" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(didStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:durationPartAnimation];
	[UIView setAnimationRepeatCount:1];
	[viewToAnim setTransform:effect3]; // apply effect
	[UIView commitAnimations];
}

- (void) animateViewPart4:(UIView*)viewToAnim {
	CGAffineTransform rotate4 = CGAffineTransformMakeRotation(  2 * M_PI * 0.25);
	rotate4 = CGAffineTransformScale( rotate4, 0.5, 0.5 );
	CGAffineTransform effect4 = CGAffineTransformConcat( [viewToAnim transform], rotate4 );
	
	[UIView beginAnimations:@"myAnimationPart4" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(didStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:durationPartAnimation];
	[UIView setAnimationRepeatCount:1];
	[viewToAnim setTransform:effect4]; // apply effect
	[UIView commitAnimations];
}


- (void) displayAddStarAnimationToPoint:(CGPoint)startPointAnimation {
    return;
	if( self.animatedStar == nil ) {
		self.animatedStar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_button_selected.png"]];
	}
	else {
		[self.animatedStar setHidden:NO];
	}
    CGPoint startPoint = startPointAnimation; // CGPointMake(10 , 35);
    // NSLog( @"STARTPOINT IS: %@", NSStringFromCGPoint(startPoint) );
	[self.animatedStar setUserInteractionEnabled:NO];
	[self.animatedStar setBackgroundColor:[UIColor clearColor]];
	[self.animatedStar setOpaque:NO];
	[self.view addSubview:self.animatedStar]; // place in view
	[self.animatedStar setFrame:CGRectMake( startPoint.x, startPoint.y, 46, 44 )];
	
	// step 2: setup animation path
	[self addAnimationPathToLayer:[self.animatedStar layer] fromPoint:startPoint];
	[self animateViewPart1:self.animatedStar];
}

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue) {
        return _operationQueue;
    }

    NSOperationQueue *operationQueue = [NSOperationQueue new];
    self.operationQueue = operationQueue;
    [operationQueue release];

    return operationQueue;
}


@end
