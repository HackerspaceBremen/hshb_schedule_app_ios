//
// Created by Karl on 04/01/15.
// Copyright (c) 2015 appdoctors. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HSHBDownloadCalendarEventsOperation : NSOperation

@property (copy, readonly) NSArray *events;
@property (nonatomic, retain) NSError *error;

@end