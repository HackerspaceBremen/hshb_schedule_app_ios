#import "DecayAnimation.h"

@implementation DecayAnimation

@synthesize omega;
@synthesize zeta;


+ (id)animationWithKeyPath:(NSString *)keyPath start:(double)start end:(double)end steps:(NSUInteger)steps {
	id animation = [self animationWithKeyPath:keyPath];
	[((DecayAnimation*)animation) setupWithOmega:30.0 zeta:0.35 start:start end:end steps:steps];
	return animation;
}

+ (id)animationWithKeyPath:(NSString *)keyPath start:(double)start end:(double)end steps:(NSUInteger)steps omega:(CGFloat)omega zeta:(CGFloat)zeta {
	id animation = [self animationWithKeyPath:keyPath];
	[((DecayAnimation*)animation) setupWithOmega:omega zeta:zeta start:start end:end steps:steps];
	return animation;
}

- (void) setupWithOmega:(double)newOmega zeta:(double)newZeta start:(double)start end:(double)end steps:(NSUInteger)steps {
    self.omega = newOmega;
    self.zeta = newZeta;
    [self initKeyframesForStartValue:start endValue:end steps:steps];
}

- (void) initKeyframesForStartValue:(double)startValue endValue:(double)endValue steps:(NSUInteger)steps {
	NSUInteger count = steps + 2;
	NSMutableArray *valueArray = [NSMutableArray array];

	double progress = 0.0;
	double increment = 1.0 / (double)(count - 1);
	NSUInteger i;
    // CALCULATE ALL ROTATION TRANSFORMATIONS FOR EACH STEP
    // CREATE TRANSFORMATIONS FOR EACH FRAME
	for( i = 0; i < count; i++ ) {
		double currentRotationValue = startValue + [self evaluateAt:progress] * (endValue - startValue);
        
        CATransform3D rotateTransform =  CATransform3DRotate(CATransform3DIdentity, radians(currentRotationValue), 0, 0, 1);
        [valueArray addObject:[NSValue valueWithCATransform3D:rotateTransform]];
		progress += increment;
	}    
	[self setValues:valueArray];
}

- (double) evaluateAt:(double)position {
	double beta = sqrt(1 - zeta * zeta);
	double phi = atan(beta / zeta);
	double result = 1.0 + -1.0 / beta * exp(-zeta * omega * position) * sin(beta * omega * position + phi);
	return result; 
}

@end
