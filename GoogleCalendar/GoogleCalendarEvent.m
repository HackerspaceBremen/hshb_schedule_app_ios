//
//  GoogCal.m
//  Election Map 2012
//
//  Created by Kurt Sparks on 2/1/12.
//  Following code included in/by 2012 none.
//

#import "GoogleCalendarEvent.h"

@implementation GoogleCalendarEvent

@synthesize uniqueId;
@synthesize originalId;
@synthesize where;
@synthesize Title;
@synthesize Description;
@synthesize EndDate;
@synthesize StartDate;
@synthesize isMarkedAsFavorite;
@synthesize publicCalendarUrl;

-(void) dealloc {
    [uniqueId release];
    [originalId release];
    [where release];
    [Title release];
    [Description release];
    [EndDate release];
    [StartDate release];
    self.publicCalendarUrl = nil;
    [super dealloc];
}

- (void) markAsFavorite {
    self.isMarkedAsFavorite = YES;
}

- (void) unmarkAsFavorite {
    self.isMarkedAsFavorite = NO;
}

@end
