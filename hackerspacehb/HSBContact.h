//
//  HSBContact.h
//  hackerspacehb
//
//  Created by trailblazr on 12.09.13.
//  Hackerspace Bremen
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"
#import "Jastor.h"

@interface HSBContact : Jastor {
    
    NSString *twitter;
    NSString *phone;
    NSString *email;
    
}


@property( nonatomic, retain ) NSString *twitter;
@property( nonatomic, retain ) NSString *phone;
@property( nonatomic, retain ) NSString *email;

+ (NSDictionary*) objectMapping;

@end
