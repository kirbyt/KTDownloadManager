//
//  KTDownloadManager.m
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTDownloadManager.h"
#import "KTDownloader.h"
#import "KTFileCache.h"


NSString * const ktDownloadManagerResponseKeyData = @"KTDownloadManager.data";
NSString * const ktDownloadManagerResponseKeyFileURL = @"KTDownloadManager.fileURL";


@interface KTDownloadManager (KTPrivateMethods)
- (void)broadcastDidFinishWithResponseData:(NSDictionary *)respData tag:(NSInteger)tag;
@end

@implementation KTDownloadManager

@synthesize delegate = downloadManagerDelegate_;

- (void)dealloc
{
   [downloaderTable_ release], downloaderTable_ = nil;
   
   [super dealloc];
}

- (id)init 
{
   self = [super init];
   if (self) {
      downloaderTable_ = [[NSMutableSet alloc] init];
   }
   return self;
}

- (void)downloadDataWithURL:(NSURL *)url 
                        tag:(NSInteger)tag 
               responseType:(KTDownloadManagerResponseType)respType;
{
   NSString *key = [url absoluteString];
   
   KTFileCache *cache = [KTFileCache sharedKTFileCache];
   NSMutableDictionary *responseData = [[NSMutableDictionary alloc] init];
   NSURL *fileURL = nil;
   NSData *data = nil;
   
   // Retrieve the file URL from the cache.
   if ((respType & KTDownloadManagerResponseTypeFileURL) == KTDownloadManagerResponseTypeFileURL) {
      fileURL = [cache fileURLWithKey:key];
      if (fileURL) {
         [responseData setObject:fileURL forKey:ktDownloadManagerResponseKeyFileURL];
      }
   }

   // If the response type includes data then
   // retrieve data from the cache.
   if ((respType & KTDownloadManagerResponseTypeData) == KTDownloadManagerResponseTypeData) {
      data = [cache dataWithKey:key];
      if (data) {
         [responseData setObject:data forKey:ktDownloadManagerResponseKeyData];
      }
   } 

   if ((respType & KTDownloadManagerResponseTypeData) == KTDownloadManagerResponseTypeData && data) {
      // No need to download. We have the data cached in memory.
      [self broadcastDidFinishWithResponseData:responseData tag:tag];
   } else if ((respType & KTDownloadManagerResponseTypeFileURL) == KTDownloadManagerResponseTypeFileURL && fileURL) {
      [self broadcastDidFinishWithResponseData:responseData tag:tag];
   } else {
      KTDownloader *downloader = [KTDownloader newDownloaderWithURL:url
                                                                tag:tag
                                                       responseType:respType
                                                    downloadManager:self];
      [downloaderTable_ addObject:downloader];
      [downloader start];
   }
}

- (NSData *)dataWithURL:(NSURL *)url
{
   NSString *key = [url absoluteString];
   KTFileCache *cache = [KTFileCache sharedKTFileCache];
   NSData *data = [cache dataWithKey:key];
   
   return data;
}


#pragma mark -
#pragma mark Delegate broadcast helpers

- (void)broadcastDidFinishWithResponseData:(NSDictionary *)respData tag:(NSInteger)tag
{
   if (downloadManagerDelegate_ && [downloadManagerDelegate_ respondsToSelector:@selector(downloadManagerDidFinishWithResponseData:tag:)]) {
      [downloadManagerDelegate_ downloadManagerDidFinishWithResponseData:respData tag:tag];
   }
}


#pragma mark -
#pragma mark KTDownloaderDelegate Methods

- (void)downloader:(KTDownloader *)downloader didFinishWithData:(NSData *)data;
{
   NSString *key = [[downloader url] absoluteString];
   NSInteger tag = [downloader tag];
   KTDownloadManagerResponseType respType = [downloader responseType];
   NSURL *fileURL = nil;
   
   NSMutableDictionary *responseData = [[NSMutableDictionary alloc] init];
   
   // Prepare cache.
   BOOL cacheToDisk = NO;
   BOOL cacheToMemory = NO;
   cacheToMemory = ((respType & KTDownloadManagerResponseTypeData) == KTDownloadManagerResponseTypeData);
   cacheToDisk =  ((respType & KTDownloadManagerResponseTypeFileURL) == KTDownloadManagerResponseTypeFileURL);

   // Cache data.
   if (respType != KTDownloadManagerResponseTypeNone) {
      KTFileCache *cache = [KTFileCache sharedKTFileCache];
      [cache storeData:data forKey:key toDisk:cacheToDisk toMemory:cacheToMemory];
      fileURL = [cache fileURLWithKey:key];
   }

   // Prepare responseData.
   if ((respType & KTDownloadManagerResponseTypeData) == KTDownloadManagerResponseTypeData) {
      [responseData setObject:data forKey:ktDownloadManagerResponseKeyData];
   }
   if ((respType & KTDownloadManagerResponseTypeFileURL) == KTDownloadManagerResponseTypeFileURL) {
      [responseData setObject:fileURL forKey:ktDownloadManagerResponseKeyFileURL];
   }
   
   // Release the downloader.
   [downloaderTable_ removeObject:downloader];
   [downloader release];

   // Return the response data to the caller.
   [self broadcastDidFinishWithResponseData:responseData tag:tag];
}

- (void)downloader:(KTDownloader *)downloader didFailWithError:(NSError *)error
{
   if (downloadManagerDelegate_ && [downloadManagerDelegate_ respondsToSelector:@selector(downloadManagerDidFailWithError:)]) {
      [downloadManagerDelegate_ downloadManagerDidFailWithError:error];
   }
   
   // Release the downloader.
   [downloaderTable_ removeObject:downloader];
   [downloader release];
}


@end
