//
//  GoogCal.h
//  Election Map 2012
//
//  Created by Kurt Sparks on 2/1/12.
//  Following code included in/by 2012 none.
//

#import <Foundation/Foundation.h>



@interface GoogleCalendarEvent : NSObject <NSCoding>
{
    NSString *uniqueId;
    NSString *originalId;
    NSString *where;
    NSString *Title;
    NSDate *StartDate;
    NSDate *EndDate;
    NSString *Description;
    NSString *publicCalendarUrl;
    BOOL isMarkedAsFavorite;
}

@property (nonatomic, assign) BOOL isMarkedAsFavorite;

@property (nonatomic, retain) NSString *uniqueId;
@property (nonatomic, retain) NSString *originalId;
@property (nonatomic, retain) NSString *where;
@property (nonatomic, retain) NSString *Title;
@property (nonatomic, retain) NSDate *StartDate;
@property (nonatomic, retain) NSDate *EndDate;
@property (nonatomic, retain) NSString *Description;
@property (nonatomic, retain) NSString *publicCalendarUrl;

- (void) markAsFavorite;
- (void) unmarkAsFavorite;

@end
