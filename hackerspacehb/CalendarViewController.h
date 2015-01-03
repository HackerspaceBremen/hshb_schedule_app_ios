//
//  CalendarViewController.h
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import <UIKit/UIKit.h>
#import "GoogleCalendarEvent.h"
#import "SilverDesignView.h"

#import "HSBStatus.h"
#import "HSBContact.h"
#import "HSBResult.h"

#import "MMPopLabel.h"

typedef enum {
    CalendarTimeIntervalCurrent = 0,
    CalendarTimeIntervalPast = 1,
    CalendarTimeIntervalFavorites = 2,
} CalendarTimeInterval;

@interface CalendarViewController : UITableViewController<UIActionSheetDelegate,UIAlertViewDelegate,MMPopLabelDelegate> {
    
    NSInteger selectedRow;
    NSMutableArray *eventsInCalender;
    UISegmentedControl *segmentedControlMenu;
    
    NSMutableDictionary *eventListCurrent;
    NSMutableArray *eventSectionKeysCurrent;
    NSMutableDictionary *eventListPast;
    NSMutableArray *eventSectionKeysPast;
    NSMutableArray *eventsFavouritedSorted;
    SilverDesignView *cellBackground;
    SilverDesignView *cellBackgroundSelected;
    CalendarTimeInterval calendarTimeIntervalSelected;
    
    UIButton *statusButton;
    HSBStatus *hackerspaceBremenStatus;
    UILabel *latestHeaderSectionLabel;
    NSTimer *timerCheckStatus;
    BOOL hasHadInitialSignAnimation;
    BOOL isRefreshingCalendarData;
    BOOL isDisplaysNoNetworkAlert;
    BOOL isDisplaysNoStatusNoNetworkAlert;
    
    UILabel *labelNoFavorites;
    UIImageView *animatedStar;
    
    MMPopLabel *refreshPopLabel;
}

@property( nonatomic, assign ) NSInteger selectedRow;
@property( nonatomic, assign ) BOOL hasHadInitialSignAnimation;
@property( nonatomic, assign ) BOOL isRefreshingCalendarData;
@property( nonatomic, assign ) BOOL isDisplaysNoNetworkAlert;
@property( nonatomic, assign ) BOOL isDisplaysNoStatusNoNetworkAlert;
@property( nonatomic, assign ) CalendarTimeInterval calendarTimeIntervalSelected;
@property( nonatomic, retain ) NSMutableArray *eventsInCalender;
@property( nonatomic, retain ) UISegmentedControl *segmentedControlMenu;
@property( nonatomic, retain ) NSMutableDictionary *eventListCurrent;
@property( nonatomic, retain ) NSMutableArray *eventSectionKeysCurrent;
@property( nonatomic, retain ) NSMutableDictionary *eventListPast;
@property( nonatomic, retain ) NSMutableArray *eventSectionKeysPast;
@property( nonatomic, retain ) SilverDesignView *cellBackground;
@property( nonatomic, retain ) SilverDesignView *cellBackgroundSelected;
@property( nonatomic, retain ) NSMutableArray *eventsFavouritedSorted;

@property( nonatomic, retain ) UIButton *statusButton;
@property( nonatomic, retain ) HSBStatus *hackerspaceBremenStatus;
@property( nonatomic, retain ) UILabel *latestHeaderSectionLabel;
@property( nonatomic, retain ) NSTimer *timerCheckStatus;
@property( nonatomic, retain ) UILabel *labelNoFavorites;
@property( nonatomic, retain ) UIImageView *animatedStar;

@property( nonatomic, retain ) MMPopLabel *refreshPopLabel;

- (IBAction) actionRefreshCalendarManually:(id)sender;

- (void) refreshCalendarDataFromUrl:(NSString*)urlString;
- (void) addEventToCalendarAtSelectedRow:(NSInteger)rowIndex;

@end
