//
//  MMLabel.m
//  MMPopLabelDemo
//
//  Created by Milton Moura on 27/05/14.
//  Following code included in/by 2014 Milton Moura.
//

#import "MMLabel.h"

@implementation MMLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // nothing to see here
    }
    return self;
}

- (void) drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {5,5,5,5};
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
