#import "NSString+AdditionEmpty.h"

@implementation NSString (NSString_AdditionEmpty)


+ (BOOL) isEmpty:(NSString*)str {
    return( str == nil || [str length] == 0 );
}


- (BOOL) isEmpty {
    return( [self length] <= 0 );
}

- (NSString*)trimmedString {
    NSMutableString *mStr = [self mutableCopy];
    CFStringTrimWhitespace( (CFMutableStringRef)mStr );
    NSString *result = [mStr copy];
    [mStr release];
    return [result autorelease];
}

- (NSString*) normalizedString {
    NSString *unaccentedString = [self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString *lowercaseString = [unaccentedString lowercaseString];
    NSString *trimmedString = [lowercaseString trimmedString];
    return trimmedString;
}

- (NSString*)placeHolderWhenEmpty:(NSString*)placeholder {
    NSString *clean = [self trimmedString];
    if( [clean length] == 0 || [[clean lowercaseString] isEqualToString:@"(null)"] ) {
        return placeholder;
    }
    else {
        return self;
    }
}

- (NSString*) httpUrlString {
    NSString* cleanTrailingSpaces = [self trimmedString];
    BOOL isHttp = [cleanTrailingSpaces containsString:@"http://" ignoringCase:YES];
    BOOL isHttps = [cleanTrailingSpaces containsString:@"https://" ignoringCase:YES];
    if( ( !isHttp && !isHttps ) && ( cleanTrailingSpaces && [cleanTrailingSpaces length] > 0 ) ) {
        return [NSString stringWithFormat:@"http://%@", cleanTrailingSpaces];
    }
    else {
        return self;
    }
}

+ (NSString*)placeHolder:(NSString*)placeholder forEmptyString:(NSString*)string {
    NSString *clean = [string trimmedString];
    if( !clean || [clean length] == 0 || [[clean lowercaseString] isEqualToString:@"(null)"] ) {
        return placeholder;
    }
    else {
        return clean;
    }
}

- (NSUInteger)integerValueFromHex {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    unsigned int result = 0;
    [scanner scanHexInt: &result];
    
    return result;
}

- (BOOL)containsString:(NSString *)stringValue {
    return [self containsString:stringValue ignoringCase:NO];
}

- (BOOL)containsString:(NSString *)stringValue ignoringCase:(BOOL)flag {
    unsigned mask = (flag ? NSCaseInsensitiveSearch : 0);
    return [self rangeOfString:stringValue options:mask].length > 0;
}

- (NSString *)wordCapitalizedString {
    NSArray *partialStrings = [self componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
    NSMutableString *capitalizedString = [NSMutableString string];
    NSString *seperator = nil;
    NSRange range;
    for( NSString* partial in partialStrings ) {
        partial = [partial sentenceCapitalizedString];
        if( [partial length] <= 3 ) {
            partial = [partial uppercaseString];
        }
        [capitalizedString appendFormat:@"%@", partial];
        range.length = 1;
        range.location = [capitalizedString length];
        seperator = nil;
        @try {
            seperator = [self substringWithRange:range];
            [capitalizedString appendFormat:@"%@", seperator];
        }
        @catch (NSException *exception) {
            //
        }
    }
    return capitalizedString;
}

- (NSString *)sentenceCapitalizedString {
    if (![self length]) {
        return [NSString string];
    }
    NSString *uppercase = [[self substringToIndex:1] uppercaseString];
    NSString *lowercase = [[self substringFromIndex:1] lowercaseString];
    return [uppercase stringByAppendingString:lowercase];
}

- (NSString *)realSentenceCapitalizedString {
    __block NSMutableString *mutableSelf = [NSMutableString stringWithString:self];
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationBySentences
                          usingBlock:^(NSString *sentence, NSRange sentenceRange, NSRange enclosingRange, BOOL *stop) {
                              [mutableSelf replaceCharactersInRange:sentenceRange withString:[sentence sentenceCapitalizedString]];
                          }];
    return [NSString stringWithString:mutableSelf]; // or just return mutableSelf.
}

- (NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    s = [s stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    return s;
}

@end
