//
//  SilverDesignView.h
//  Nautical
//
//  Created by trailblazr on 30.03.13.
//
//

#import <UIKit/UIKit.h>

@interface SilverDesignView : UIView {

    UIColor *colorTop;
    UIColor *colorBottom;
    UIColor *colorLineBright;
    UIColor *colorLineDark;
    BOOL showTopBottomLines;
    BOOL useFancyGradient;
    BOOL hasRoundCornersTop;
    BOOL hasRoundCornersBottom;
}

@property( nonatomic, assign ) BOOL showTopBottomLines;
@property( nonatomic, assign ) BOOL useFancyGradient;
@property( nonatomic, assign ) BOOL hasRoundCornersTop;
@property( nonatomic, assign ) BOOL hasRoundCornersBottom;
@property( nonatomic, retain ) UIColor *colorTop;
@property( nonatomic, retain ) UIColor *colorBottom;
@property( nonatomic, retain ) UIColor *colorLineBright;
@property( nonatomic, retain ) UIColor *colorLineDark;

@end
