//
//  ViewController.h
//  hackerspacehb
//
//  Created by trailblazr on 09.09.13.
//  Hackerspace Bremen
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "GoogleCalendarEvent.h"
#import "AMSmoothAlertView.h"
#import "AMSmoothAlertConstants.h"


typedef enum {
    EventKitAlertNoAccess,
    EventKitAlertAlreadyPresent,
    EventKitAlertErrorWhileWriting,
    EventKitAlertAddedSuccessfully,
    EventKitAlertDeletedSuccessfully,
    EventKitAlertEventNotFound,
} EventKitAlert;

@interface EventDetailViewController : UIViewController<MFMailComposeViewControllerDelegate,AMSmoothAlertViewDelegate> {
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *dateTimeLabel;
    IBOutlet UILabel *favoriteBannerLabel;
    IBOutlet UITextView *descriptionTextView;
    
    GoogleCalendarEvent *eventToDisplay;
    EKEventStore *eventStore;
}

@property( nonatomic, retain ) GoogleCalendarEvent *eventToDisplay;
@property( nonatomic, retain ) UILabel *titleLabel;
@property( nonatomic, retain ) UILabel *dateTimeLabel;
@property( nonatomic, retain ) UILabel *favoriteBannerLabel;
@property( nonatomic, retain ) UITextView *descriptionTextView;
@property( nonatomic, retain ) EKEventStore *eventStore;

@end
