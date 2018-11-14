//
//  SettingsViewController.m
//  hackerspacehb
//
//  Created by trailblazr on 14.09.13.
//  Hackerspace Bremen
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "HSBApplication.h"

@implementation SettingsViewController


@synthesize uidTextField;
@synthesize pwdTextField;
@synthesize msgTextView;
@synthesize versionLabel;
@synthesize uidLabel;
@synthesize pwdLabel;
@synthesize msgLabel;
@synthesize infoLabel;
@synthesize isEditingTextView;
@synthesize spaceMessages;
@synthesize spaceMessageControl;
@synthesize reminderTimeControl;

- (void) dealloc {
    self.uidTextField = nil;
    self.pwdTextField = nil;
    self.msgTextView = nil;
    self.versionLabel = nil;
    self.uidLabel = nil;
    self.pwdLabel = nil;
    self.msgLabel = nil;
    self.infoLabel = nil;
    self.spaceMessages = nil;
    self.spaceMessageControl = nil;
    self.reminderTimeControl = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - convenience

- (AppDelegate*) appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void) togglePassword {
    pwdTextField.secureTextEntry = !pwdTextField.secureTextEntry;
    pwdLabel.textColor = pwdTextField.secureTextEntry ? [UIColor whiteColor] : [UIColor redColor];
    if( pwdTextField.secureTextEntry ) {
        [self stopFlashing];
    }
    else {
        [self startFlashing];
    }
}

- (void) addFlashingAnimationToView:(UIView*)viewToFlash duration:(NSTimeInterval)duration toValue:(CGFloat)toValue afterDelay:(NSTimeInterval)delay {
    [viewToFlash.layer removeAllAnimations];
    if( duration == 0.0 ) {
        return;
    }
    viewToFlash.layer.opacity = 1.0;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = duration;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.beginTime = delay; // ATTN: THIS IS OF UTMOST IMPORTANCE TO AVOID FLASHING AFTER THE TABLEVIEW APPEARS
    [viewToFlash.layer addAnimation:animation forKey:@"animateOpacity"];
}

- (void) startFlashing {
    [self addFlashingAnimationToView:pwdLabel duration:1.0 toValue:0.2 afterDelay:0.2];
}

- (void) stopFlashing {
    [pwdLabel.layer removeAllAnimations];
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
    self.navigationItem.title = @"Zugangsdaten";
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.spaceMessageControl.tintColor = [UIColor whiteColor];
    self.reminderTimeControl.tintColor = [UIColor whiteColor];

    // LOAD MESSAGES
    NSDictionary *storedMessages = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_SPACE_MESSAGES];
    if( !storedMessages ) {
        self.spaceMessages = [NSMutableDictionary dictionary];
        for( int i = 0; i < 4; i++ ) {
            NSString *messageKey = [NSString stringWithFormat:@"message_%i", (int)i];
            [spaceMessages setObject:kTEXTVIEW_PLACEHOLDER forKey:messageKey];
        }
        [[NSUserDefaults standardUserDefaults] setObject:spaceMessages forKey:kUSER_DEFAULTS_SPACE_MESSAGES];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        self.spaceMessages = [NSMutableDictionary dictionaryWithDictionary:storedMessages];
    }
    // LOAD ACTIVE INDEX
    NSUInteger activeMessageIndex = 0;
    if( [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_SPACE_MESSAGE_ACTIVE] ) {
        activeMessageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kUSER_DEFAULTS_SPACE_MESSAGE_ACTIVE];
        [spaceMessageControl setSelectedSegmentIndex:activeMessageIndex];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setInteger:activeMessageIndex forKey:kUSER_DEFAULTS_SPACE_MESSAGE_ACTIVE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    NSUInteger reminderTimeIndex = 0;
    if( [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_REMINDER_TIME_ACTIVE] ) {
        reminderTimeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kUSER_DEFAULTS_REMINDER_TIME_ACTIVE];
        [reminderTimeControl setSelectedSegmentIndex:reminderTimeIndex];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setInteger:reminderTimeIndex forKey:kUSER_DEFAULTS_REMINDER_TIME_ACTIVE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    
    versionLabel.text = [HSBApplication versionStringVerbose];

    if( [[UIDevice currentDevice] isOS_7] ) {
        self.view.backgroundColor = kCOLOR_HACKERSPACE;
        versionLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        uidLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        pwdLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        msgLabel.shadowOffset = CGSizeMake(0.0, 0.0);
        infoLabel.shadowOffset = CGSizeMake(0.0, 0.0);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    uidTextField.text = [[self appDelegate] tokenStoredWithKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    pwdTextField.text = [[self appDelegate] tokenStoredWithKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    msgTextView.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_MSG];
    if( !msgTextView.text || [msgTextView.text length] == 0 ) {
        msgTextView.text = kTEXTVIEW_PLACEHOLDER;
    }
    [self textViewDidChange:msgTextView];
    msgTextView.layer.cornerRadius = 4;
    msgTextView.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
    msgTextView.layer.borderWidth = 0.5f;
    
    msgTextView.editable = YES;
    
    uidTextField.tintColor = kCOLOR_HACKERSPACE;
    pwdTextField.tintColor = kCOLOR_HACKERSPACE;
    msgTextView.tintColor = kCOLOR_HACKERSPACE;
    
    // NSLog( @"pwdTextField.text = %@", pwdTextField.text );
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    //UIBarButtonItem *validateItem = [[[UIBarButtonItem alloc] initWithTitle:@"Validieren" style:UIBarButtonItemStylePlain target:self action:@selector(actionValidateLogin:)] autorelease];
    //self.navigationItem.rightBarButtonItem = validateItem;

    UIBarButtonItem *revealItem = [[[UIBarButtonItem alloc] initWithTitle:@"Passwort" style:UIBarButtonItemStylePlain target:self action:@selector(actionPasswordToggle:)] autorelease];
    self.navigationItem.rightBarButtonItem = revealItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - user actions -

- (IBAction) actionPasswordToggle:(id)sender {
    if( pwdTextField.secureTextEntry == false ) {
        [self togglePassword];
        return;
    }
    LAContext *myContext = [[LAContext alloc] init];
    NSString *supportedBiometry = @"Authentifizierungsmethode";
    if (@available(iOS 11.0, *)) {
        LABiometryType availableBiometryType = myContext.biometryType;
        switch( availableBiometryType ) {
            case LABiometryTypeNone:
                supportedBiometry = @"Passwort";
                break;
                
            case LABiometryTypeTouchID:
                supportedBiometry = @"Touch ID";
                break;
                
            case LABiometryTypeFaceID:
                supportedBiometry = @"Face ID";
                break;
                
            default:
                supportedBiometry = @"Authentifizierungsmethode";
                break;
        }
    } else {
        // Fallback on earlier versions
    }
    NSString *myLocalizedReasonString = [NSString stringWithFormat:@"Wir benötigen eine Authentifizierung per %@ um dir Zugriff zu deinen Zugangsdaten zu geben.", supportedBiometry];
    /*
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Biometrie"
                                                                   message:[NSString stringWithFormat:@"Wir werden dich jetzt authentifizieren mittels '%@'.", supportedBiometry]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Authentifizieren..." style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self initBiometricAuthWithContext:myContext andReason:myLocalizedReasonString];
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
     */
    // START AUTH
    [self initBiometricAuthWithContext:myContext andReason:myLocalizedReasonString];
}

- (void) initBiometricAuthWithContext:(LAContext*)myContext andReason:(NSString*)myLocalizedReasonString {
    
    NSError *authError = nil;
    
    LAPolicy preferredPolicy = LAPolicyDeviceOwnerAuthentication; // LAPolicyDeviceOwnerAuthenticationWithBiometrics, LAPolicyDeviceOwnerAuthentication
    
    if ([myContext canEvaluatePolicy:preferredPolicy error:&authError]) {
        [myContext evaluatePolicy:preferredPolicy
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    // User authenticated successfully, take appropriate action
                                    /*
                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Zugangsdaten"
                                                                                                   message:@"Dein Passwort wird in Klartext freigegeben zur Einsicht für dich."
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action) {
                                                                                          }];
                                    
                                    [alert addAction:defaultAction];
                                    [self presentViewController:alert animated:YES completion:nil];
                                     */
                                    dispatch_async( dispatch_get_main_queue() , ^{
                                        [self togglePassword];
                                    });
                                    
                                }
                                else {
                                    // User did not authenticate successfully, look at error and take appropriate action
                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Zugangsdaten"
                                                                                                   message:@"Zugang verweigert, um dein Passwort einsehen zu können musst du dich erfolgreich authentifizieren."
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action) {}];
                                    
                                    [alert addAction:defaultAction];
                                    [self presentViewController:alert animated:YES completion:nil];
                                }
                            }];
    }
    else {
        // Could not evaluate policy; look at authError and present an appropriate message to user
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Authentifizierungsfehler"
                                                                       message:[NSString stringWithFormat:@"Could not evaluate authentication policy.\nAUTHERROR:\n%@", authError]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (IBAction) actionChangeReminderTime:(UISegmentedControl*)control {
    NSUInteger reminderTimeIndex = control.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:reminderTimeIndex forKey:kUSER_DEFAULTS_REMINDER_TIME_ACTIVE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[self appDelegate] rescheduleAllFavorites];
}

- (IBAction) actionChangeActiveMessage:(UISegmentedControl*)control {
    NSUInteger activeMessageIndex = control.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:activeMessageIndex forKey:kUSER_DEFAULTS_SPACE_MESSAGE_ACTIVE];
    NSString *messageKey = [NSString stringWithFormat:@"message_%lu", (unsigned long)activeMessageIndex];
    msgTextView.text = [spaceMessages objectForKey:messageKey];
    [self textViewDidChange:msgTextView];
    [[NSUserDefaults standardUserDefaults] setObject:msgTextView.text forKey:kUSER_DEFAULTS_OPEN_SPACE_MSG];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction) actionValidateLogin:(id)sender {
    [uidTextField resignFirstResponder];
    [pwdTextField resignFirstResponder];
    [msgTextView resignFirstResponder];
    if( uidTextField.text && [uidTextField.text length] > 0 && pwdTextField.text && [pwdTextField.text length] > 0 ) {
        NSString *message = [NSString stringWithFormat:@"Zugangsdaten bzw. Benutzerkennung und Passwort sind gültig!"];


        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Verifizierung"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"Zugangsdaten bzw. Benutzerkennung und Passwort sind ungültig!"];

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Verifizierung"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (void) saveAllValues {
    @synchronized( [NSUserDefaults standardUserDefaults] ) {
        [[self appDelegate] tokenStore:uidTextField.text withKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
        [[self appDelegate] tokenStore:pwdTextField.text withKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
        [[NSUserDefaults standardUserDefaults] setObject:msgTextView.text forKey:kUSER_DEFAULTS_OPEN_SPACE_MSG];
        // UPDATE STORED MESSAGES
        NSString *messageKey = [NSString stringWithFormat:@"message_%li", (long)spaceMessageControl.selectedSegmentIndex];
        if( msgTextView.text && [msgTextView.text length] > 0 ) {
            [self.spaceMessages setObject:msgTextView.text forKey:messageKey];
            [[NSUserDefaults standardUserDefaults] setObject:self.spaceMessages forKey:kUSER_DEFAULTS_SPACE_MESSAGES];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - UITextView delegate -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    /*
    if ( [text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
        [self saveAllValues];
        return NO;
    }
    else {
        return YES;
    }
     */
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if( [msgTextView.text isEqualToString:kTEXTVIEW_PLACEHOLDER] ) {
        textView.text = @"";
        msgTextView.textColor = kTEXTVIEW_FEEDBACK_COLOR_WRITE;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithTitle:@"Fertig" style:UIBarButtonItemStylePlain target:self action:@selector(actionDoneEditing:)] autorelease];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    isEditingTextView = YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    UIBarButtonItem *revealItem = [[[UIBarButtonItem alloc] initWithTitle:@"Passwort" style:UIBarButtonItemStylePlain target:self action:@selector(actionPasswordToggle:)] autorelease];
    [self.navigationItem setRightBarButtonItem:revealItem animated:YES];
    if( msgTextView.text == nil || [msgTextView.text length] == 0 ) {
        msgTextView.text = kTEXTVIEW_PLACEHOLDER;
    }
    if( [msgTextView.text isEqualToString:kTEXTVIEW_PLACEHOLDER] ) {
        msgTextView.textColor = kTEXTVIEW_FEEDBACK_COLOR_PLACE;
    }
    else {
        msgTextView.textColor = kTEXTVIEW_FEEDBACK_COLOR_WRITE;
    }
    isEditingTextView = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    if( [textView.text isEqualToString:kTEXTVIEW_PLACEHOLDER] ) {
        msgTextView.textColor = kTEXTVIEW_FEEDBACK_COLOR_PLACE;
    }
    else {
        msgTextView.textColor = kTEXTVIEW_FEEDBACK_COLOR_WRITE;
    }
}


#pragma mark - UITextField delegate -

- (void) textFieldDidBeginEditing:(UITextField *)textField {

}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [msgTextView resignFirstResponder];
    [self saveAllValues];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if( textField == uidTextField ) {
        [pwdTextField becomeFirstResponder];
    }
    if( textField == pwdTextField ) {
        [msgTextView becomeFirstResponder];
    }
    [self saveAllValues];
   return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (IBAction) actionTextContentDidChange:(UITextField*)textField {
}

- (IBAction) actionDoneEditing:(id)sender {
    [msgTextView resignFirstResponder];
    [self saveAllValues];
}

@end
