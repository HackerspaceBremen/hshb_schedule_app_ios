//
// Created by Karl on 04/01/15.
// Copyright (c) 2015 appdoctors. All rights reserved.
//

#import "GoogleCalendarEvent+HSHBAdditions.h"
#import "JTISO8601DateFormatter.h"


@implementation GoogleCalendarEvent (HSHBAdditions)

static id hshb_NoNSNull(id value)
{
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

static NSDate *hshb_DateFromDictionary(id value)
{
    if (!value) {
        return nil;
    }

    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSDictionary *dictionary = (NSDictionary *) value;


    NSDate *date = nil;

    NSString *timeString = hshb_NoNSNull(dictionary[@"dateTime"]);

    if (timeString) {

        JTISO8601DateFormatter *dateFormatter = [JTISO8601DateFormatter new];

        NSString *timeZone = hshb_NoNSNull(dictionary[@"timeZone"]);
        if (timeZone) {
            dateFormatter.defaultTimeZone = [NSTimeZone timeZoneWithName:timeZone];
        }
        date = [dateFormatter dateFromString:timeString];

        [dateFormatter release];
    } else {

        NSString *dateString = hshb_NoNSNull(dictionary[@"date"]);
        if (dateString) {

            JTISO8601DateFormatter *dateFormatter = [JTISO8601DateFormatter new];

            date = [dateFormatter dateFromString:dateString];

            [dateFormatter release];

        }

    }

    return date;

}

+ (instancetype)hshb_eventFromDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return nil;
    }

    NSString *status = hshb_NoNSNull(dictionary[@"status"]);
    if ([status isEqualToString:@"cancelled"]) {
        return nil;
    }

    GoogleCalendarEvent *event = [[[GoogleCalendarEvent alloc] init] autorelease];
    event.Title = hshb_NoNSNull(dictionary[@"summary"]);
    event.originalId = hshb_NoNSNull(dictionary[@"recurringEventId"]);
    event.uniqueId = hshb_NoNSNull(dictionary[@"id"]);
    event.publicCalendarUrl = hshb_NoNSNull(dictionary[@"htmlLink"]);
    event.where = hshb_NoNSNull(dictionary[@"location"]);
    event.Description = hshb_NoNSNull(dictionary[@"description"]);
    event.StartDate = hshb_DateFromDictionary(dictionary[@"start"]);
    event.EndDate = hshb_DateFromDictionary(dictionary[@"end"]);

    return event;
}


@end