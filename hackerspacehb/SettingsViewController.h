//
//  SettingsViewController.h
//  hackerspacehb
//
//  Created by trailblazr on 14.09.13.
//  Hackerspace Bremen
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "AMSmoothAlertView.h"
#import "AMSmoothAlertConstants.h"

@interface SettingsViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate> {

    IBOutlet UITextField *uidTextField;
    IBOutlet UITextField *pwdTextField;
    IBOutlet UITextView *msgTextView;
    IBOutlet UILabel *versionLabel;
    IBOutlet UILabel *uidLabel;
    IBOutlet UILabel *pwdLabel;
    IBOutlet UILabel *msgLabel;
    IBOutlet UILabel *infoLabel;
    IBOutlet UISegmentedControl *spaceMessageControl;
    BOOL isEditingTextView;
    NSMutableDictionary *spaceMessages;
    
}


@property( nonatomic, retain ) UITextField *uidTextField;
@property( nonatomic, retain ) UITextField *pwdTextField;
@property( nonatomic, retain ) UITextView *msgTextView;
@property( nonatomic, retain ) UILabel *versionLabel;
@property( nonatomic, retain ) UILabel *uidLabel;
@property( nonatomic, retain ) UILabel *pwdLabel;
@property( nonatomic, retain ) UILabel *msgLabel;
@property( nonatomic, retain ) UILabel *infoLabel;
@property( nonatomic, retain ) UISegmentedControl *spaceMessageControl;
@property( nonatomic, retain ) NSMutableDictionary *spaceMessages;
@property( nonatomic, assign ) BOOL isEditingTextView;

- (IBAction) actionTextContentDidChange:(UITextField*)textField;

@end
