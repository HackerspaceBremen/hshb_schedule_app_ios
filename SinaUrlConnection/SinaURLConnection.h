#import <Foundation/Foundation.h>

typedef void (^URLConnectionCompletionBlock)        (NSData *data, NSURLResponse *response);
typedef void (^URLConnectioErrorBlock)              (NSError *error);
typedef void (^URLConnectioUploadProgressBlock)     (float progress);
typedef void (^URLConnectioDownloadProgressBlock)   (float progress);


@interface SinaURLConnection : NSObject 

+ (SinaURLConnection*)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock
                        errorBlock:(URLConnectioErrorBlock)errorBlock
               uploadProgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
             downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;

+ (SinaURLConnection*)asyncConnectionWithRequest:(NSURLRequest *)request
                                 completionBlock:(URLConnectionCompletionBlock)completionBlock
                                      errorBlock:(URLConnectioErrorBlock)errorBlock
                             uploadProgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
                           downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock
                            expectedDownloadSize:(NSNumber*)expectedDownloadSize;

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock 
                        errorBlock:(URLConnectioErrorBlock)errorBlock;

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(URLConnectionCompletionBlock)completionBlock 
                          errorBlock:(URLConnectioErrorBlock)errorBlock;

- (void)cancel;

@end