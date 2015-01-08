//
// Created by Karl on 04/01/15.
// Copyright (c) 2015 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleCalendarEvent.h"

@interface GoogleCalendarEvent (HSHBAdditions)

+ (instancetype)hshb_eventFromDictionary:(NSDictionary *)dictionary;

@end