//
//  AMBouncingView.h
//  AMSmoothAlertViewDemo
//
//  Created by AMarliac on 2014-04-25.
//  Following code included in/by 2014 AMarliac.
//

#import <UIKit/UIKit.h>
#import "AMSmoothAlertConstants.h"

@interface AMBouncingView : UIView

@property (nonatomic, strong) UIImageView* image;

- (id)initSuccessCircleWithFrame:(CGRect)frame andImageSize:(int) imageSize forAlertType:(AlertType) type andColor:(UIColor*) color;
- (CGRect) newFrameWithWidth:(float) width andHeight:(float) height;

@end
