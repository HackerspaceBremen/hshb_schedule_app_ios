//
//  HSBError.h
//  hackerspacehb
//
//  Created by trailblazr on 14.09.13.
//  Hackerspace Bremen
//

#import "Jastor.h"

@interface HSBError : Jastor {

    NSString *errorMessage;
    NSNumber *errorCode;

}

@property( nonatomic, retain ) NSString *errorMessage;
@property( nonatomic, retain ) NSNumber *errorCode;

+ (NSDictionary*) objectMapping;

@end
