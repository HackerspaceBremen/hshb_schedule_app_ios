//
//  SettingsViewController.m
//  hackerspacehb
//
//  Created by trailblazr on 14.09.13.
//  Hackerspace Bremen
//

#import "SettingsViewController.h"

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
        // Custom initialization
    }
    return self;
}

#pragma mark - view handling

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Zugangsdaten";
    if( [[UIDevice currentDevice] isOS_7] ) {
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // LOAD MESSAGES
    self.spaceMessages = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_SPACE_MESSAGES];
    if( !spaceMessages ) {
        self.spaceMessages = [NSMutableDictionary dictionary];
        for( int i = 0; i < 4; i++ ) {
            NSString *messageKey = [NSString stringWithFormat:@"message_%i", (int)i];
            [spaceMessages setObject:kTEXTVIEW_PLACEHOLDER forKey:messageKey];
        }
        [[NSUserDefaults standardUserDefaults] setObject:spaceMessages forKey:kUSER_DEFAULTS_SPACE_MESSAGES];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    NSString *buildVersionString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSString *buildNumberString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger units = (NSCalendarUnitYear );
    NSDateComponents *components = [calendar components:units fromDate:today];
    NSUInteger yearFrom = 2013;
    NSUInteger yearTo = components.year;
    versionLabel.text = [NSString stringWithFormat:@"Hackerspace Bremen\nv%@ / build %@, %lu-%lu by trailblazr", buildVersionString, buildNumberString, (unsigned long)yearFrom, (unsigned long)yearTo];

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
    uidTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    pwdTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
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
    
    UIBarButtonItem *validateItem = [[[UIBarButtonItem alloc] initWithTitle:@"Validieren" style:UIBarButtonItemStylePlain target:self action:@selector(actionValidateLogin:)] autorelease];
    self.navigationItem.rightBarButtonItem = validateItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - user actions -

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
        AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Verifizierung" andText:message andCancelButton:NO forAlertType:AlertSuccess];
        [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        alert.cornerRadius = 3.0f;
        [alert show];
        [alert release];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"Zugangsdaten bzw. Benutzerkennung und Passwort sind ungültig!"];
        AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Verifizierung" andText:message andCancelButton:NO forAlertType:AlertFailure];
        [alert setTitleFont:[UIFont fontWithName:@"Verdana" size:25.0f]];
        [alert.defaultButton setTitle:@"OK" forState:UIControlStateNormal];
        alert.cornerRadius = 3.0f;
        [alert show];
        [alert release];
    }
}

#pragma mark - UITextFieldDelegate

- (void) saveAllValues {
    [[NSUserDefaults standardUserDefaults] setObject:uidTextField.text forKey:kUSER_DEFAULTS_OPEN_SPACE_UID];
    [[NSUserDefaults standardUserDefaults] setObject:pwdTextField.text forKey:kUSER_DEFAULTS_OPEN_SPACE_PWD];
    [[NSUserDefaults standardUserDefaults] setObject:msgTextView.text forKey:kUSER_DEFAULTS_OPEN_SPACE_MSG];

    // UPDATE STORED MESSAGES
    NSString *messageKey = [NSString stringWithFormat:@"message_%li", (long)spaceMessageControl.selectedSegmentIndex];
    [spaceMessages setObject:msgTextView.text forKey:messageKey];
    [[NSUserDefaults standardUserDefaults] setObject:spaceMessages forKey:kUSER_DEFAULTS_SPACE_MESSAGES];

    [[NSUserDefaults standardUserDefaults] synchronize];
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
    UIBarButtonItem *validateItem = [[[UIBarButtonItem alloc] initWithTitle:@"Validieren" style:UIBarButtonItemStylePlain target:self action:@selector(actionValidateLogin:)] autorelease];
    [self.navigationItem setRightBarButtonItem:validateItem animated:YES];
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
