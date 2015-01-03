#import "SinaURLConnection.h"

@interface SinaURLConnection () {
    NSURLConnection *connection;
    NSURLRequest    *request;
    NSMutableData   *data;
    NSURLResponse   *response;
    long long       downloadSize;
    NSNumber        *expectedDownloadSize;
    
    URLConnectionCompletionBlock completionBlock;
    URLConnectioErrorBlock errorBlock;
    URLConnectioUploadProgressBlock uploadBlock;
    URLConnectioDownloadProgressBlock downloadBlock;
}

- (id)initWithRequest:(NSURLRequest *)request 
      completionBlock:(URLConnectionCompletionBlock)completionBlock
           errorBlock:(URLConnectioErrorBlock)errorBlock
  uploadProgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock;
- (void)start;

@end

@implementation SinaURLConnection

+ (SinaURLConnection*)asyncConnectionWithRequest:(NSURLRequest *)request
                                 completionBlock:(URLConnectionCompletionBlock)completionBlock
                                      errorBlock:(URLConnectioErrorBlock)errorBlock
                             uploadProgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
                           downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock {
    
    SinaURLConnection *sinaConnection = [[[SinaURLConnection alloc] initWithRequest:request
                                                                    completionBlock:completionBlock
                                                                         errorBlock:errorBlock
                                                                uploadProgressBlock:uploadBlock
                                                              downloadProgressBlock:downloadBlock] autorelease];
    [sinaConnection start];
    return sinaConnection;
}

+ (SinaURLConnection*)asyncConnectionWithRequest:(NSURLRequest *)request
                                 completionBlock:(URLConnectionCompletionBlock)completionBlock
                                      errorBlock:(URLConnectioErrorBlock)errorBlock
                             uploadProgressBlock:(URLConnectioUploadProgressBlock)uploadBlock
                           downloadProgressBlock:(URLConnectioDownloadProgressBlock)downloadBlock
                            expectedDownloadSize:(NSNumber*)expectedDownloadSize {
    
    SinaURLConnection *sinaConnection = [[[SinaURLConnection alloc] initWithRequest:request
                                                                    completionBlock:completionBlock
                                                                         errorBlock:errorBlock
                                                                uploadProgressBlock:uploadBlock
                                                              downloadProgressBlock:downloadBlock
                                                               expectedDownloadSize:expectedDownloadSize] autorelease];
    [sinaConnection start];
    return sinaConnection;
}

+ (void)asyncConnectionWithRequest:(NSURLRequest *)request 
                   completionBlock:(URLConnectionCompletionBlock)completionBlock 
                        errorBlock:(URLConnectioErrorBlock)errorBlock {
    [SinaURLConnection asyncConnectionWithRequest:request 
                              completionBlock:completionBlock 
                                   errorBlock:errorBlock 
                          uploadProgressBlock:nil 
                        downloadProgressBlock:nil];
}

+ (void)asyncConnectionWithURLString:(NSString *)urlString
                     completionBlock:(URLConnectionCompletionBlock)completionBlock 
                          errorBlock:(URLConnectioErrorBlock)errorBlock {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [SinaURLConnection asyncConnectionWithRequest:request 
                              completionBlock:completionBlock 
                                   errorBlock:errorBlock];
}



- (id)initWithRequest:(NSURLRequest *)_request
      completionBlock:(URLConnectionCompletionBlock)_completionBlock
           errorBlock:(URLConnectioErrorBlock)_errorBlock
  uploadProgressBlock:(URLConnectioUploadProgressBlock)_uploadBlock
downloadProgressBlock:(URLConnectioDownloadProgressBlock)_downloadBlock {
    
    self = [super init];
    if (self) {
        request =           [_request retain];
        completionBlock =   [_completionBlock copy];
        errorBlock =        [_errorBlock copy];
        uploadBlock =       [_uploadBlock copy];
        downloadBlock =     [_downloadBlock copy];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)_request
      completionBlock:(URLConnectionCompletionBlock)_completionBlock
           errorBlock:(URLConnectioErrorBlock)_errorBlock
  uploadProgressBlock:(URLConnectioUploadProgressBlock)_uploadBlock
downloadProgressBlock:(URLConnectioDownloadProgressBlock)_downloadBlock
 expectedDownloadSize:(NSNumber*)_expectedDownloadSize{
    
    self = [super init];
    if (self) {
        request =           [_request retain];
        completionBlock =   [_completionBlock copy];
        errorBlock =        [_errorBlock copy];
        uploadBlock =       [_uploadBlock copy];
        downloadBlock =     [_downloadBlock copy];
        expectedDownloadSize = [_expectedDownloadSize copy];
    }
    return self;
}

- (void)dealloc {
    [request release];
    [data release];
    [response release];
    [completionBlock release];
    [errorBlock release];
    [uploadBlock release];
    [downloadBlock release];
    [connection release];
    [super dealloc];
}

- (void)start {
    connection  = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    data        = [[NSMutableData alloc] init];
    
    [connection start];    
}

- (void)cancel {
    [connection cancel];
}

#pragma mark NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection {
    if(completionBlock) completionBlock(data, response);
}

- (void)connection:(NSURLConnection *)_connection 
  didFailWithError:(NSError *)error {
    if(errorBlock) errorBlock(error);
}

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSHTTPURLResponse *)_response {
    response = [_response retain];
    if( [response expectedContentLength] == -1 ) {
        if( expectedDownloadSize ) {
            downloadSize = [expectedDownloadSize longLongValue];
        }
    }
    else {
        downloadSize = [response expectedContentLength];
    }
    if( DEBUG ) NSLog( @"SinaURLConnection: expectedContentLength = %lli bytes", downloadSize  );
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)_data {
    [data appendData:_data];

    if( DEBUG ) NSLog( @"SinaURLConnection: dataReceivedLength = %.0f bytes", (float)data.length  );

    if (downloadSize != -1) {
        float progress = (float)data.length / (float)downloadSize;
        if( progress > 1.0f ) {
            progress = 1.0f;
        }
        if(downloadBlock) downloadBlock(progress);
    }
}

- (void)connection:(NSURLConnection *)connection   
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float progress= (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
    if (uploadBlock) uploadBlock(progress);
}


@end
