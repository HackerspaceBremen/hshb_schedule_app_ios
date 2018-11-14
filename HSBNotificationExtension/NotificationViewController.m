//
//  NotificationViewController.m
//  HSBNotificationExtension
//
//  Created by trailblazr on 13.11.18.
//  Copyright © 2018 appdoctors. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *subTitleLabel;
@property IBOutlet UIImageView *imageViewSign;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
}

- (void)didReceiveNotification:(UNNotification *)notification {
    // NSString *currentStatus = [notification.request.content.userInfo objectForKey:@"status"];
    NSString *message = [notification.request.content.userInfo objectForKey:@"message"];
    self.subTitleLabel.text = message;
    UNNotificationAttachment *attachment = [notification.request.content.attachments firstObject];
    self.imageViewSign.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:attachment.URL]];
}

@end
