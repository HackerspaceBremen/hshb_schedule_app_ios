//
// Created by Karl on 04/01/15.
// Copyright (c) 2015 appdoctors. All rights reserved.
//

#import "NSString+HSHBAdditions.h"


@implementation NSString (HSHBAdditions)

- (instancetype)hshb_urlEncodedWithEncoding:(NSStringEncoding)encoding
{
    NSString *encodedString = (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", CFStringConvertNSStringEncodingToEncoding(encoding));
    
    return [encodedString autorelease];
}


@end