//
// Created by Karl on 04/01/15.
// Copyright (c) 2015 appdoctors. All rights reserved.
//

#import "HSHBDownloadCalendarEventsOperation.h"
#import "NSString+HSHBAdditions.h"
#import "JTISO8601DateFormatter.h"
#import "GoogleCalendarEvent.h"
#import "GoogleCalendarEvent+HSHBAdditions.h"

@interface HSHBDownloadCalendarEventsOperation () <NSURLConnectionDataDelegate>

@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isExecuting) BOOL executing;
@property (retain) NSURLConnection *connection;
@property (retain) NSMutableData *data;
@property (retain) NSMutableArray *mutableEvents;

@end


@implementation HSHBDownloadCalendarEventsOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (void)dealloc
{
    [_mutableEvents release];
    [_connection release];
    [_data release];
    [_error release];

    [super dealloc];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    _mutableEvents = [NSMutableArray new];
    _finished = NO;
    _executing = NO;

    return self;
}

- (void)start
{
    if (self.isCancelled) {
        [self markAsFinished];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self loadEventsWithPageToken:nil];
}

- (void)markAsFinished
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (NSURL *)urlWithPageToken:(NSString *)pageToken
{
    NSMutableString *urlString = [NSMutableString string];

    NSCalendar *calendar = [[NSCalendar currentCalendar] retain];

    NSDate *now = [[NSDate date] retain];

    NSDateComponents *backwardDateComponents = [NSDateComponents new];
    backwardDateComponents.year = -1;

    NSDate *fromDate = [calendar dateByAddingComponents:backwardDateComponents toDate:now options:0];

    [backwardDateComponents release];

    NSDateComponents *forwardDateComponents = [NSDateComponents new];
    forwardDateComponents.day = 100;

    NSDate *toDate = [calendar dateByAddingComponents:forwardDateComponents toDate:now options:0];

    [forwardDateComponents release];

    // BASEURL (CONTAINS API KEY)
    [urlString appendString:kGOOGLE_CALENDAR_URL];

    JTISO8601DateFormatter *dateFormatter = [JTISO8601DateFormatter new];
    dateFormatter.includeTime = NO;

    NSString *timeMinString = [dateFormatter stringFromDate:fromDate];
    NSString *timeMaxString = [dateFormatter stringFromDate:toDate];

    [dateFormatter release];

    timeMinString = [timeMinString stringByAppendingString:@"T00:00:00+10:00"];
    timeMaxString = [timeMaxString stringByAppendingString:@"T23:59:00+10:00"];

    [urlString appendString:@"?orderBy=startTime"];
    [urlString appendFormat:@"&timeMin=%@", [timeMinString hshb_urlEncodedWithEncoding:NSUTF8StringEncoding]];
    [urlString appendFormat:@"&timeMax=%@", [timeMaxString hshb_urlEncodedWithEncoding:NSUTF8StringEncoding]];
    if (pageToken) {
        [urlString appendFormat:@"&pageToken=%@", pageToken];
    }
    [urlString appendString:@"&singleEvents=true"];

    [urlString appendFormat:@"&key=%@", [kGOOGLE_CALENDAR_API_KEY hshb_urlEncodedWithEncoding:NSUTF8StringEncoding]];

    [now release];
    [calendar release];

    return [NSURL URLWithString:urlString];
}

- (void)loadEventsWithPageToken:(NSString *)pageToken
{
    NSURL *url = [self urlWithPageToken:pageToken];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection setDelegateQueue:[NSOperationQueue currentQueue]];

    self.connection = connection;
    [connection release];

    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [connection start];
}

- (void)handleResponseData:(NSData *)data
{
    NSError *error;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (!response) {
        if (DEBUG) NSLog(@"failed to parse json data: %@", error);

        // TODO fail operation

        [self markAsFinished];
    }

    // parse items

    NSArray *itemDictionaries = response[@"items"];

    for (NSDictionary *itemDictionary in itemDictionaries) {

        GoogleCalendarEvent *event = [GoogleCalendarEvent hshb_eventFromDictionary:itemDictionary];
        if (!event) {
            continue;
        }

        [self.mutableEvents addObject:event];

    }

    NSString *nextPageToken = response[@"nextPageToken"];
    if (nextPageToken) {

        [self loadEventsWithPageToken:nextPageToken];

    } else {

        [self markAsFinished];

    }

}

- (void)cancel
{
    if (_connection) {
        [_connection cancel];
    }

    [super cancel];
}

- (NSArray *)events
{
    return [[_mutableEvents copy] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *) response;
        if (httpurlResponse.statusCode != 200) {

            if (DEBUG) NSLog(@"request did not finish as expected");

            self.error = [NSError errorWithDomain:@"HackerspaceBremenErrorDomain" code:2342 userInfo:nil];

        }

    }

    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;

    if ([_data length] > 0) {

        [self handleResponseData:_data];
        self.data = nil;

    } else {

        [self markAsFinished];

    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
    [self markAsFinished];
}

@end