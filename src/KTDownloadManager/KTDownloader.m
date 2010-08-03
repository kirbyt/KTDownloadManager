//
//  KTDownloadManager.m
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTDownloader.h"
#import "KTDownloadManager.h"

@interface KTDownloader ()
@property (nonatomic, assign) KTDownloadManager *downloadManager;
@property (nonatomic, retain) NSMutableData *receivedData;
@end


@implementation KTDownloader

@synthesize url = url_;
@synthesize downloadManager = downloadManager_;
@synthesize receivedData = receivedData_;
@synthesize tag = tag_;
@synthesize responseType = responseType_;

- (void)dealloc 
{
   [url_ release], url_ = nil;
   [receivedData_ release], receivedData_ = nil;
   
   [super dealloc];
}

+ (KTDownloader *)newDownloaderWithURL:(NSURL *)url 
                                   tag:(NSInteger)tag 
                          responseType:(KTDownloadManagerResponseType)respType
                       downloadManager:(KTDownloadManager *)downloadManager
{
   KTDownloader *downloader = [[KTDownloader alloc] init];
   [downloader setUrl:url];
   [downloader setTag:tag];
   [downloader setResponseType:respType];
   [downloader setDownloadManager:downloadManager];
   return downloader;
}

- (void)start 
{
   NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url_];
   NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self
                                                         startImmediately:NO];
   [request release];
   
   [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSRunLoopCommonModes];
   [connection start];
   
   if (connection) {
      NSMutableData *data = [[NSMutableData alloc] init];
      [self setReceivedData:data];
      [data release];
   } else {
      NSError *error = [NSError errorWithDomain:KTDownloaderErrorDomain
                                           code:KTDownloaderErrorNoConnection
                                       userInfo:nil];
      if (downloadManager_) {
         [downloadManager_ downloader:self didFailWithError:error];
      }
   }
}


#pragma mark -
#pragma mark NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   [[self receivedData] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   [[self receivedData] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   [connection release];
   if (downloadManager_) {
      [downloadManager_ downloader:self didFailWithError:error];
   }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   [connection release];
   
   NSData *data = [self receivedData];
   [downloadManager_ downloader:self didFinishWithData:data];
}


@end
