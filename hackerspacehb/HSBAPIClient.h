#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface HSBAPIClient : AFHTTPClient

+ (HSBAPIClient *)sharedClient;

@end
