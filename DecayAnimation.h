#import <QuartzCore/CoreAnimation.h>

@interface DecayAnimation : CAKeyframeAnimation {
    
    CGFloat omega;
	CGFloat zeta;

}

@property( nonatomic, assign ) CGFloat omega;
@property( nonatomic, assign ) CGFloat zeta;

+ (id)animationWithKeyPath:(NSString *)keyPath start:(double)start end:(double)end steps:(NSUInteger)steps;
+ (id)animationWithKeyPath:(NSString *)keyPath start:(double)start end:(double)end steps:(NSUInteger)steps omega:(CGFloat)omega zeta:(CGFloat)zeta;
- (void) setupWithOmega:(double)newOmega zeta:(double)newZeta start:(double)start end:(double)end steps:(NSUInteger)steps;
- (void) initKeyframesForStartValue:(double)startValue endValue:(double)endValue steps:(NSUInteger)steps;
- (double) evaluateAt:(double)position;


@end
