//
//  ViewController.m
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import "EventDetailViewController.h"
#import "CalendarViewController.h"
#import "AppDelegate.h"
#import "HSBStatus.h"
#import "HSBContact.h"
#import "HSBResult.h"
#import "NSString+AdditionEmpty.h"

#define kACTIONSHEET_EVENT_DETAIL_ASK_ACTION 200

@implementation EventDetailViewController

@synthesize eventToDisplay;
@synthesize titleLabel;
@synthesize dateTimeLabel;
@synthesize descriptionTextView;
@synthesize favoriteBannerLabel;
@synthesize eventStore;

- (void) dealloc {
    self.eventToDisplay = nil;
    self.dateTimeLabel = nil;
    self.titleLabel = nil;
    self.descriptionTextView = nil;
    self.favoriteBannerLabel = nil;
    self.eventStore = nil;
    [super dealloc];
}

#pragma mark - convenience methods

- (AppDelegate*) appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark - view handling

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL) prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    favoriteBannerLabel.alpha = 0.0;
    self.navigationItem.title = @"Veranstaltung";
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIBarButtonItem *actionItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionRememberInCalendar:)] autorelease];
    self.navigationItem.rightBarButtonItem = actionItem;
    
    self.dateTimeLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    self.titleLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    favoriteBannerLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    [[self view] bringSubviewToFront:favoriteBannerLabel];
    descriptionTextView.tintColor = kCOLOR_HACKERSPACE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [df setLocale:locale];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterFullStyle;
    NSString *dateString = [df stringFromDate:eventToDisplay.StartDate];
    [df setDateFormat:@"H:mm"];
    
    NSString *dateTimeString = [NSString stringWithFormat:@"%@\n%@ bis %@ Uhr", dateString, [df stringFromDate:eventToDisplay.StartDate], [df stringFromDate:eventToDisplay.EndDate]];
    dateTimeLabel.text = dateTimeString;
    
    [df release];
    df = nil;
    titleLabel.text = eventToDisplay.Title;
    NSMutableString *descriptionText = [NSMutableString string];
    if( eventToDisplay.Description ) {
        [descriptionText appendFormat:@"%@", eventToDisplay.Description];
    }
    if( eventToDisplay.where ) {
        if( [descriptionText length] > 0 ) {
            [descriptionText appendString:@"\n\n"];
        }
        [descriptionText appendFormat:@"%@", eventToDisplay.where];
    }
    descriptionText = [NSMutableString stringWithString:[descriptionText stringByStrippingHTML]];
    descriptionTextView.text = [NSString stringWithString:descriptionText];
    
    /*
    CGFloat fontSize = 16.0;
    descriptionTextView.font = [descriptionTextView.font fontWithSize:fontSize];
    if( descriptionText && [descriptionText length] > 0 ) {
        
        NSString *fontColorHex = [[UIColor blackColor] hexStringFromColor];
        NSString *htmlHeader = [NSString stringWithFormat:@"<html><head><meta charset=\"utf-8\"></head><body style=\"color:#%@;font-family:%@;font-size:%ipx;\">", fontColorHex, @"Avenir-Medium", (int)fontSize];
        NSString *htmlFooter = [NSString stringWithFormat:@"</body></html>"];
        NSString *htmlContent = [NSString stringWithFormat:@"%@%@%@", htmlHeader,descriptionText,htmlFooter];
        NSData *htmlAsData = [htmlContent dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithData:htmlAsData options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil] autorelease];
        
        descriptionTextView.font = [UIFont boldSystemFontOfSize:fontSize];
        descriptionTextView.textColor = [UIColor blackColor];
        descriptionTextView.backgroundColor = [UIColor clearColor];
        descriptionTextView.attributedText = attributedString;
    }
    */
    
    
    // CONFIGURE TOOLBAR
    BOOL useToolbar = NO;
    if( useToolbar ) {
        UIBarButtonItem *spacerItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *spacerStatic1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        UIBarButtonItem *spacerStatic2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spacerStatic1.width = 20.0;
        spacerStatic2.width = 20.0;
        UIBarButtonItem *actionItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionRememberInCalendar:)] autorelease];
        UIBarButtonItem *addToCalendarItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddToCalendar)] autorelease];
            
        NSArray *toolBarItems = @[spacerStatic1,addToCalendarItem, spacerItem1, actionItem,spacerStatic2];
        [self setToolbarItems:toolBarItems animated:YES];
    }
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    // ADJUST BANNER
    favoriteBannerLabel.transform = CGAffineTransformIdentity;
    favoriteBannerLabel.center = CGPointMake( self.view.bounds.size.width-50, self.view.bounds.size.height-25.0);
    favoriteBannerLabel.transform = CGAffineTransformMakeRotation( radians(-20.0) );
    favoriteBannerLabel.autoresizesSubviews = NO;
    favoriteBannerLabel.autoresizingMask = UIViewAutoresizingNone;
}

- (void)viewDidLayoutSubviews {
    favoriteBannerLabel.center = CGPointMake( self.view.bounds.size.width-50, self.view.bounds.size.height-25.0);
}

- (void) updateFavoriteLabel {
    [UIView animateWithDuration:0.3 animations:^{
        BOOL isInCalendarOrFavorite = NO;
        if( eventToDisplay.isMarkedAsFavorite ) {
            isInCalendarOrFavorite = YES;
        }
        if( [self hasEventInCalendar] ) {
            isInCalendarOrFavorite = YES;
        }
        favoriteBannerLabel.alpha = isInCalendarOrFavorite ? 1.0 : 0.0;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateFavoriteLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventKit:) name:kNOTIFICATION_ALERT_ALREADY_PRESENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventKit:) name:kNOTIFICATION_ALERT_SOME_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventKit:) name:kNOTIFICATION_ALERT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventKit:) name:kNOTIFICATION_ALERT_NO_ACCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventKit:) name:kNOTIFICATION_ALERT_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationEventKit:) name:kNOTIFICATION_ALERT_NOT_FOUND object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - eventkit stuff

- (void)notificationEventKit:(NSNotification*)notification {
    if( [notification.name isEqualToString:kNOTIFICATION_ALERT_ALREADY_PRESENT] ) {
        [self presentAlertForEvent:EventKitAlertAlreadyPresent error:nil];
    }
    if( [notification.name isEqualToString:kNOTIFICATION_ALERT_SOME_ERROR] ) {
        [self presentAlertForEvent:EventKitAlertErrorWhileWriting error:nil];
    }
    if( [notification.name isEqualToString:kNOTIFICATION_ALERT_SUCCESS] ) {
        [self presentAlertForEvent:EventKitAlertAddedSuccessfully error:nil];
    }
    if( [notification.name isEqualToString:kNOTIFICATION_ALERT_NO_ACCESS] ) {
        [self presentAlertForEvent:EventKitAlertNoAccess error:nil];
    }
    if( [notification.name isEqualToString:kNOTIFICATION_ALERT_DELETED] ) {
        [self presentAlertForEvent:EventKitAlertDeletedSuccessfully error:nil];
    }
    if( [notification.name isEqualToString:kNOTIFICATION_ALERT_NOT_FOUND] ) {
        [self presentAlertForEvent:EventKitAlertEventNotFound error:nil];
    }
}

- (void) presentAlertForEvent:(EventKitAlert)alertType error:(NSError*)error {
    
    UIAlertController* alert = nil;
    
    switch( alertType ) {
        case EventKitAlertNoAccess: {
            NSString *message = [NSString stringWithFormat:@"Eintrag fehlgeschlagen, bitte Kalenderzugriff erlauben."];

            alert = [UIAlertController alertControllerWithTitle:@"Kalender"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            
            break;
        }
            
        case EventKitAlertAlreadyPresent: {
            NSString *message = [NSString stringWithFormat:@"Eintrag existiert bereits, Duplikat verhindert!"];

            alert = [UIAlertController alertControllerWithTitle:@"Kalender"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];

            break;
        }
            
        case EventKitAlertErrorWhileWriting: {
            NSString *message = [NSString stringWithFormat:@"Eintrag fehlgeschlagen. Grund ist unbekannt!"];

            alert = [UIAlertController alertControllerWithTitle:@"Kalender"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];

            break;
        }
            
        case EventKitAlertAddedSuccessfully: {
            NSString *message = [NSString stringWithFormat:@"Eintrag in den Standardkalender übertragen."];

            alert = [UIAlertController alertControllerWithTitle:@"Kalender"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];

            break;
        }

        case EventKitAlertDeletedSuccessfully: {
            NSString *message = [NSString stringWithFormat:@"Eintrag aus dem Standardkalender entfernt."];

            alert = [UIAlertController alertControllerWithTitle:@"Kalender"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];

            break;
        }

        case EventKitAlertEventNotFound: {
            NSString *message = [NSString stringWithFormat:@"Eintrag existierte nicht im Standardkalender, daher nicht gelöscht."];

            alert = [UIAlertController alertControllerWithTitle:@"Kalender"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];

            break;
        }

        default:
            break;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - user actions

- (IBAction) actionRememberInCalendar:(id)sender {
    NSString *sheetTitle = @"Veranstaltung in";
    EKAuthorizationStatus calendarAccessStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    BOOL isAllowedToAccess = ( calendarAccessStatus == EKAuthorizationStatusAuthorized );
    BOOL hasEventInCalendar = NO;
    if( isAllowedToAccess ) {
        hasEventInCalendar = [self hasEventInCalendar];
    }
    if( hasEventInCalendar ) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:sheetTitle
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* shareFullTextAction = [UIAlertAction actionWithTitle:@"Volltext teilen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self actionShareFullText];
        }];
        
        UIAlertAction* shareShortTextAction = [UIAlertAction actionWithTitle:@"Kurztext teilen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // TWITTER TEILEN
            [self actionShareShortText];
        }];

        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction* removeAction = [UIAlertAction actionWithTitle:@"Kalender entfernen" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            // EVENT LOESCHEN
            [self actionRemoveFromCalendar];
        }];

        [alert addAction:removeAction];
        [alert addAction:shareFullTextAction];
        [alert addAction:shareShortTextAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:sheetTitle
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* shareFullTextAction = [UIAlertAction actionWithTitle:@"Volltext teilen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self actionShareFullText];
        }];

        UIAlertAction* shareShortTextAction = [UIAlertAction actionWithTitle:@"Kurztext teilen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            // TWITTER TEILEN
            [self actionShareShortText];
        }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction* removeAction = [UIAlertAction actionWithTitle:@"Kalender eintragen" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            // EVENT EINTRAGEN
            [self actionAddToCalendar];
        }];
        
        [alert addAction:removeAction];
        [alert addAction:shareFullTextAction];
        [alert addAction:shareShortTextAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL) hasEventInCalendar {
    @try {
        self.eventStore = [[[EKEventStore alloc] init] autorelease];
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = eventToDisplay.Title;
        event.startDate = eventToDisplay.StartDate;
        event.endDate   = eventToDisplay.EndDate;
        event.URL = [NSURL URLWithString:eventToDisplay.uniqueId];
        [event setNotes:eventToDisplay.Description];
        NSPredicate *eventMatchPredicate = [eventStore predicateForEventsWithStartDate:eventToDisplay.StartDate endDate:eventToDisplay.EndDate calendars:@[eventStore.defaultCalendarForNewEvents]];
        
        NSArray *eventsFound = [eventStore eventsMatchingPredicate:eventMatchPredicate];
        if( eventsFound && [eventsFound count] > 0 ) {
            return YES;
        }
        else {
            return NO;
        }
    } @catch (NSException *exception) {
        return NO;
    }
}

- (IBAction) actionAddToCalendar {
    self.eventStore = [[[EKEventStore alloc] init] autorelease];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if( granted ) {
            EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
            event.title     = eventToDisplay.Title;
            event.startDate = eventToDisplay.StartDate;
            event.endDate   = eventToDisplay.EndDate;
            event.URL = [NSURL URLWithString:eventToDisplay.uniqueId];
            [event setNotes:eventToDisplay.Description];
            NSPredicate *eventMatchPredicate = [eventStore predicateForEventsWithStartDate:eventToDisplay.StartDate endDate:eventToDisplay.EndDate calendars:@[eventStore.defaultCalendarForNewEvents]];
            
            NSArray *eventsFound = [eventStore eventsMatchingPredicate:eventMatchPredicate];
            
            BOOL isAlreadyPresent = NO;
            if( eventsFound && [eventsFound count] > 0 ) {
                NSString *urlString = [[NSURL URLWithString:eventToDisplay.uniqueId] absoluteString];
                for( EKEvent *currentEvent in eventsFound ) {
                    if( [[currentEvent.URL absoluteString] isEqualToString:urlString] ) {
                        isAlreadyPresent = YES;
                    }
                }
            }
            if( isAlreadyPresent ) { // DO NOT ADD EVENT
                LOG( @"ERROR EVENT ALREADY IN CALENDAR: %@", eventToDisplay.Title );
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_ALREADY_PRESENT object:nil];
                });
            }
            else { // TRY TO ENTER EVENT
                [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                NSError *error = nil;
                [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
                if( error ) {
                    LOG( @"ERROR PUSHING EVENT TO CALENDAR: %@", error );
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_SOME_ERROR object:error];
                        [self updateFavoriteLabel];
                    });
                }
                else {
                    LOG( @"EVENT PUSHED TO CALENDAR: %@", eventToDisplay.Title );
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_SUCCESS object:error];
                        [self updateFavoriteLabel];
                    });

                }
            }
        }
        else {
            LOG( @"NO ACCESS. PUSHING EVENT TO CALENDAR: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_NO_ACCESS object:error];
            });
        }
    }];
}

- (IBAction) actionRemoveFromCalendar {
    self.eventStore = [[[EKEventStore alloc] init] autorelease];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if( granted ) {
            EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
            event.title     = eventToDisplay.Title;
            event.startDate = eventToDisplay.StartDate;
            event.endDate   = eventToDisplay.EndDate;
            event.URL = [NSURL URLWithString:eventToDisplay.uniqueId];
            [event setNotes:eventToDisplay.Description];
            NSPredicate *eventMatchPredicate = [eventStore predicateForEventsWithStartDate:eventToDisplay.StartDate endDate:eventToDisplay.EndDate calendars:@[eventStore.defaultCalendarForNewEvents]];
            
            NSArray *eventsFound = [eventStore eventsMatchingPredicate:eventMatchPredicate];
            
            EKEvent *eventToDelete = nil;
            if( eventsFound && [eventsFound count] > 0 ) {
                NSString *urlString = [[NSURL URLWithString:eventToDisplay.uniqueId] absoluteString];
                for( EKEvent *currentEvent in eventsFound ) {
                    if( [[currentEvent.URL absoluteString] isEqualToString:urlString] ) {
                        eventToDelete = currentEvent;
                        break;
                    }
                }
            }
            if( eventToDelete ) { // REMOVE EVENT NOW

                NSError *error = nil;
                [eventStore removeEvent:eventToDelete span:EKSpanThisEvent error:&error];
                if( error ) {
                    LOG( @"ERROR DELETING EVENT FROM CALENDAR: %@", error );
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_SOME_ERROR object:error];
                        [self updateFavoriteLabel];
                    });
                }
                else {
                    LOG( @"EVENT REMOVED FROM CALENDAR: %@", eventToDisplay.Title );
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_DELETED object:error];
                        [self updateFavoriteLabel];
                    });
                }
            }
            else { // DO NOTHING EVENT NOT FOUND
                LOG( @"EVENT NOT FOUND IN CALENDAR: %@", eventToDisplay.Title );
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_NOT_FOUND object:nil];
                });
            }
        }
        else {
            LOG( @"NO ACCESS. REMOVING EVENT FROM CALENDAR: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ALERT_NO_ACCESS object:error];
            });
        }
    }];
    [self updateFavoriteLabel];
}

- (IBAction)actionShareFullText {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [df setLocale:locale];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterFullStyle;
    NSString *dateString = [df stringFromDate:eventToDisplay.StartDate];
    [df setDateFormat:@"H:mm"];
    
    NSString *payloadDateTimeString = [NSString stringWithFormat:@"%@\n%@ bis %@ Uhr", dateString, [df stringFromDate:eventToDisplay.StartDate], [df stringFromDate:eventToDisplay.EndDate]];
    
    [df release];
    df = nil;
    
    NSString *payloadTitle = eventToDisplay.Title;
    
    NSMutableString *descriptionText = [NSMutableString string];
    if( eventToDisplay.Description ) {
        [descriptionText appendFormat:@"%@", eventToDisplay.Description];
    }
    if( eventToDisplay.where ) {
        if( [descriptionText length] > 0 ) {
            [descriptionText appendString:@"\n\n"];
        }
        [descriptionText appendFormat:@"%@", eventToDisplay.where];
    }
    NSString *payloadBody = [NSString stringWithString:descriptionText];
    
    
    NSString *contentMailSubjectText = @"Veranstaltungstipp Hackerspace Bremen e.V.";
    
    NSString *contentBrandingText = [NSString stringWithFormat:@"%@\n\n%@\n%@\n\n%@\n\n%@:\n%@ %@\nim AppStore:\n%@", contentMailSubjectText, payloadTitle,payloadDateTimeString,  payloadBody, @"Quelle", @"Hackerspace Bremen e.V.", @"(iOS App)", kHACKERSPACE_APPSTORE_URL];
    
    NSArray *itemsToShare = nil;
    itemsToShare = @[contentBrandingText];
    
    NSArray *applicationActivities = @[];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:applicationActivities];
    // SET E-MAIL SUBJECT
    [controller setValue:contentMailSubjectText forKey:@"subject"];
    
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypePostToWeibo];
    
    controller.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        LOG( @" activityType: %@ completed: %@", activityType, completed ? @"YES" : @"NO" );
    };
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (IBAction) actionShareShortText {
    
    // MESSAGE COMPOSING
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title     = eventToDisplay.Title;
    event.startDate = eventToDisplay.StartDate;
    event.endDate   = eventToDisplay.EndDate;
    event.URL = [NSURL URLWithString:eventToDisplay.uniqueId];
    [event setNotes:eventToDisplay.Description];

    NSString *twitterAccount = kHACKERSPACE_DEFAULT_TWITTER_ACCOUNT;
    if( [self appDelegate].hackerspaceBremenStatus ) {
        NSString *twitterAccountFromStatus = [self appDelegate].hackerspaceBremenStatus.spaceContact.twitter;
        if( twitterAccountFromStatus && [twitterAccountFromStatus length] > 0 ) {
            // REMOVE @-symbols WE PUT THEM IN
            twitterAccountFromStatus = [twitterAccountFromStatus stringByReplacingOccurrencesOfString:@"@" withString:@""];
            twitterAccount = twitterAccountFromStatus;
        }
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.doesRelativeDateFormatting = YES;
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterShortStyle;
    NSString *eventDate = [df stringFromDate:eventToDisplay.StartDate];
    [df release];
    BOOL hasWhereInfo = ( eventToDisplay.where && [eventToDisplay.where length] > 0 );
    if( [[eventToDisplay.where lowercaseString] rangeOfString:@"hackerspace bremen"].location != NSNotFound ) {
        hasWhereInfo = NO;
    }
    NSString *whereString = hasWhereInfo ? [NSString stringWithFormat:@"%@", eventToDisplay.where] : @"im";
    NSString *sharedMessage = [NSString stringWithFormat:@"%@ @%@: %@, %@ #hackerspace #bremen ", eventDate, twitterAccount, eventToDisplay.Title, whereString];
    
    NSURL *eventUrl = [NSURL URLWithString:eventToDisplay.publicCalendarUrl];
    UIImage *imageToShare = [UIImage imageNamed:@"Icon_60.png"];
    
    NSArray *itemsToShare = nil;
    itemsToShare = @[sharedMessage,eventUrl, imageToShare];
    
    NSArray *applicationActivities = @[];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:applicationActivities];
    // SET E-MAIL SUBJECT
    NSString *contentMailSubjectText = @"Veranstaltungstipp Hackerspace Bremen e.V.";
    [controller setValue:contentMailSubjectText forKey:@"subject"];
    
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact,UIActivityTypePostToWeibo];
    
    controller.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        LOG( @" activityType: %@ completed: %@", activityType, completed ? @"YES" : @"NO" );
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction) actionRateViaTwitter {
    
}

- (IBAction) actionShareViaMail {
    
}


#pragma mark - Create Mail Message

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// [self becomeFirstResponder];
	[controller setDelegate:nil];
	switch (result) {
		case MFMailComposeResultCancelled: {
            BOOL shouldSHowAlert = NO;
            if( shouldSHowAlert ) {
                NSString *message = [NSString stringWithFormat:@"Versenden der E-Mail wurde unterbrochen/abgebrochen!"];

                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"E-Mail"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
			break;
        }
            
		case MFMailComposeResultSaved: {
            NSString *message = [NSString stringWithFormat:@"Mail wurde für späteren Versand gespeichert!"];

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"E-Mail"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

			break;
        }
		case MFMailComposeResultSent: {
            NSString *message = [NSString stringWithFormat:@"Mail wurde versendet!"];

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"E-Mail"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

			break;
        }
            
		case MFMailComposeResultFailed: {
            NSString *message = [NSString stringWithFormat:@"Versand fehlgeschlagen!"];

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"E-Mail"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];

			break;
        }
            
		default:
			break;
	}
}

/*
- (NSString*) htmlMailBodyForObject:(id)object {
    NSMutableString *htmlString = [NSMutableString string];
    [htmlString appendFormat:@"<html><body>"];
    [htmlString appendFormat:@"<p><strong>%@:</strong></p>", @"29c3 Favorit(en)"];
    [htmlString appendString:@"<p>"];
    
    [htmlString appendString:[NSString placeHolder:@"Keine Informtion" forEmptyString:[self stringRepresentationMailFor:object]]];
    
    [htmlString appendString:@"</p>"];
    [htmlString appendString:@"</body></html>"];
    return htmlString;
}

- (void) actionShareObjectViaMail:(id)objectToShare {
    NSLog( @"SHARE VIA MAIL");
    if ( ![MFMailComposeViewController canSendMail] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Sie haben derzeit keinen E-Mail-Account auf ihrem Gerät konfiguriert. Bitte zunächst das Mail App in Betrieb nehmen!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return;
    }
    NSArray* toRecipients = [NSArray array];
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:toRecipients];
    [controller setSubject:@"29c3 Veranstaltungstipp"];
    NSString *message = [self htmlMailBodyForObject:objectToShare];
    [controller setMessageBody:message isHTML:YES];
    [[self navigationController] presentModalViewController:controller animated:YES];
    [controller.navigationBar setBarTintColor:kCOLOR_HACKERSPACE];
    [controller release];
}

- (void)sendMailToRecipientAddress:(NSString*)mailTo {
    if( !mailTo || [mailTo length] == 0 ) return;
    if ( ![MFMailComposeViewController canSendMail] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"E-Mail" message:@"Sie haben derzeit keinen E-Mail-Account auf ihrem Gerät konfiguriert. Bitte zunächst das Mail App in Betrieb nehmen!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return;
    }
    NSArray* toRecipients = [NSArray arrayWithObject:mailTo];
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:toRecipients];
    [controller setSubject:@"Kontaktaufnahme auf dem 29c3"];
    NSString *message = @"Hallo,\n\n";
    [controller setMessageBody:message isHTML:NO];
    [[self navigationController] presentModalViewController:controller animated:YES];
    [controller.navigationBar setBarTintColor:kCOLOR_HACKERSPACE];
    [controller release];
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)actionAddToSystemCalendar:(id)sender {
    
}

@end
