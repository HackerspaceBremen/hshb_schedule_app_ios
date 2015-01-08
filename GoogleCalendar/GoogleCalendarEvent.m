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

#pragma mark NSCoding

static NSString *const GoogleCalendarEventCodingKeyUniqueId = @"uniqueId";
static NSString *const GoogleCalendarEventCodingKeyOriginalId = @"originalId";
static NSString *const GoogleCalendarEventCodingKeyWhere = @"where";
static NSString *const GoogleCalendarEventCodingKeyTitle = @"Title";
static NSString *const GoogleCalendarEventCodingKeyDescription = @"Description";
static NSString *const GoogleCalendarEventCodingKeyEndDate = @"EndDate";
static NSString *const GoogleCalendarEventCodingKeyStartDate = @"StartDate";
static NSString *const GoogleCalendarEventCodingKeyIsMarkedAsFavorite = @"isMarkedAsFavorite";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) return nil;

    uniqueId = (NSString *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyUniqueId] retain];
    originalId = (NSString *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyOriginalId] retain];
    where = (NSString *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyWhere] retain];
    Title = (NSString *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyTitle] retain];
    Description = (NSString *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyDescription] retain];
    EndDate = (NSDate *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyEndDate] retain];
    StartDate = (NSDate *) [[aDecoder decodeObjectForKey:GoogleCalendarEventCodingKeyStartDate] retain];
    isMarkedAsFavorite = [aDecoder decodeBoolForKey:GoogleCalendarEventCodingKeyIsMarkedAsFavorite];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:uniqueId forKey:GoogleCalendarEventCodingKeyUniqueId];
    [aCoder encodeObject:originalId forKey:GoogleCalendarEventCodingKeyOriginalId];
    [aCoder encodeObject:where forKey:GoogleCalendarEventCodingKeyWhere];
    [aCoder encodeObject:Title forKey:GoogleCalendarEventCodingKeyTitle];
    [aCoder encodeObject:Description forKey:GoogleCalendarEventCodingKeyDescription];
    [aCoder encodeObject:EndDate forKey:GoogleCalendarEventCodingKeyEndDate];
    [aCoder encodeObject:StartDate forKey:GoogleCalendarEventCodingKeyStartDate];
    [aCoder encodeBool:isMarkedAsFavorite forKey:GoogleCalendarEventCodingKeyIsMarkedAsFavorite];
}

@end
