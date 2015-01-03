//
//  SilverDesignView.m
//  Nautical
//
//  Created by trailblazr on 30.03.13.
//
//

#import "SilverDesignView.h"

@implementation SilverDesignView

@synthesize colorTop;
@synthesize colorBottom;
@synthesize colorLineBright;
@synthesize colorLineDark;
@synthesize showTopBottomLines;
@synthesize useFancyGradient;
@synthesize hasRoundCornersTop;
@synthesize hasRoundCornersBottom;

- (void) dealloc {
    self.colorTop = nil;
    self.colorBottom = nil;
    self.colorLineBright = nil;
    self.colorLineDark = nil;
    self.hasRoundCornersBottom = NO;
    self.hasRoundCornersTop = NO;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showTopBottomLines = YES;
        self.useFancyGradient = NO;
        self.hasRoundCornersBottom = NO;
        self.hasRoundCornersTop = NO;
        self.colorTop = [UIColor colorWithHexString:@"ffffff"];
        self.colorBottom = [UIColor colorWithHexString:@"fafafa"];
        self.colorLineBright = [UIColor whiteColor];
        self.colorLineDark = [[UIColor grayColor] colorByLighteningTo:0.8];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();

    CGFloat cornerRadius = 10.0;
    if( hasRoundCornersTop ) {
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx;
        miny = miny;
		
        maxx = maxx;
        maxy = maxy;
		
        // LEFT TOP EDGE
        CGContextMoveToPoint(c, minx, maxy); // BOTTOM-LEFT
        CGContextAddArcToPoint(c, minx, miny, midx, miny, cornerRadius); // TOP-LEFT - CENTER
        CGContextAddLineToPoint(c, maxx, miny); // TOP-RIGHT
        CGContextAddLineToPoint(c, maxx, maxy); // BOTTOM-RIGHT
		
        CGContextClosePath(c);
        CGContextClip(c);

    
        // RIGHT TOP EDGE
        CGContextMoveToPoint(c, maxx, maxy); // BOTTOM-RIGHT
        CGContextAddArcToPoint(c, maxx, miny, midx, miny, cornerRadius); // TOP-RIGHT - CENTER
        CGContextAddLineToPoint(c, minx, miny); // TOP-LEFT
        CGContextAddLineToPoint(c, minx, maxy); // BOTTOM-LEFT
        CGContextClosePath(c);
        CGContextClip(c);
        
    }

    if( hasRoundCornersBottom ) {
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx;
        miny = miny;
		
        maxx = maxx;
        maxy = maxy;
		
        // LEFT BOTTOM EDGE
        CGContextMoveToPoint(c, minx, miny); // TOP-LEFT
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, cornerRadius); // BOTTOM-LEFT - CENTER
        CGContextAddLineToPoint(c, maxx, maxy); // BOTTOM-RIGHT
        CGContextAddLineToPoint(c, maxx, miny); // TOP-RIGHT

        CGContextClosePath(c);
		CGContextClip(c);
        
        // RIGHT BOTTOM EDGE
        CGContextMoveToPoint(c, maxx, miny); // TOP-RIGHT
        CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, cornerRadius); // BOTTOM-RIGHT - CENTER
        CGContextAddLineToPoint(c, minx, maxy); // BOTTOM-LEFT
        CGContextAddLineToPoint(c, minx, miny); // TOP-LEFT
        CGContextClosePath(c);
		CGContextClip(c);
        
    }

    CGContextSetFillColorWithColor( c, colorBottom.CGColor );
    CGContextFillRect( c , rect );
    
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGPoint start, end;
    if( useFancyGradient ) {
        start = CGPointMake( floor(rect.size.width/2.0f)-0.5f, 4.0f );
        end = CGPointMake( floor(rect.size.width/2.0f)+1.2f, rect.size.height-1.0f );
    }
    else {
        start = CGPointMake( 0.0f, 0.0f );
        end = CGPointMake( 0.0f, rect.size.height);
    }
    /*
     CGFloat locations[2];
     locations[0] = 0.0;
     locations[1] = 1.0;
     */
    
    UIColor *uicolor1 = colorTop;
    UIColor *uicolor2 = colorBottom;

    const CGFloat* componentsColor1 = CGColorGetComponents( uicolor1.CGColor );
    int numOfColors1 = CGColorGetNumberOfComponents( uicolor1.CGColor );
	const CGFloat* componentsColor2 = CGColorGetComponents( uicolor2.CGColor );
    int numOfColors2 = CGColorGetNumberOfComponents( uicolor2.CGColor );
    
    // FIX BUG ON <IOS4
    CGColorRef color1,color2;
    if( numOfColors1 == 2 ) { // monochrome color
        color1 = [UIColor colorWithRed:componentsColor1[0] green:componentsColor1[0] blue:componentsColor1[0] alpha:componentsColor1[1]].CGColor;
    }
    else {
        color1 = [UIColor colorWithRed:componentsColor1[0] green:componentsColor1[1] blue:componentsColor1[2] alpha:componentsColor1[3]].CGColor;
    }
    if( numOfColors2 == 2 ) { // monochrome color
        color2 = [UIColor colorWithRed:componentsColor2[0] green:componentsColor2[0] blue:componentsColor2[0] alpha:componentsColor2[1]].CGColor;
    }
    else {
        color2 = [UIColor colorWithRed:componentsColor2[0] green:componentsColor2[1] blue:componentsColor2[2] alpha:componentsColor2[3]].CGColor;
    }
    
    // CGColorRef color1 = CGColorRetain(colorTop.CGColor);
    // CGColorRef color2 = CGColorRetain(colorBottom.CGColor);
    NSArray *colors = [NSArray arrayWithObjects:(id)color1,(id)color2, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(rgb, (CFArrayRef)colors, NULL );
    CGColorSpaceRelease(rgb);
    
	CGContextDrawLinearGradient(c, gradient, start, end, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);

    if( showTopBottomLines ) {
        CGFloat lineWidth = 1.0f;
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineWidth);
        
        // BLACK FRAME
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), colorLineDark.CGColor ); // RGB COLOR
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0.0f, rect.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), rect.size.width, rect.size.height);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        
        // WHITE FRAME
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), colorLineBright.CGColor ); // RGB COLOR
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0.0f, 0.0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), rect.size.width, 0.0);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
    }
    CGGradientRelease(gradient);
}

@end
