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

@interface KTDownloadManager (KTPrivateMethods)
- (void)broadcastDidFinishWithFileURL:(NSURL *)fileURL tag:(NSInteger)tag;
- (void)broadcastDidFinishWithData:(NSData *)data tag:(NSInteger)tag;
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
                    caching:(KTDownloadManagerCaching)caching;
{
   NSString *key = [url absoluteString];
   
   KTFileCache *cache = [KTFileCache sharedKTFileCache];
   NSURL *fileURL = [cache fileURLWithKey:key];
   NSData *data = [cache dataWithKey:key];

   if ((caching && KTDownloadManagerCachingMemory) == KTDownloadManagerCachingMemory && data) {
      // No need to download. We have the data cached in memory.
      [self broadcastDidFinishWithData:data tag:tag];
   } else if ((caching && KTDownloadManagerCachingFileSystem) == KTDownloadManagerCachingFileSystem && fileURL) {
      [self broadcastDidFinishWithFileURL:fileURL tag:tag];
   } else {
      KTDownloader *downloader = [KTDownloader newDownloaderWithURL:url
                                                                tag:tag
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

- (void)broadcastDidFinishWithFileURL:(NSURL *)fileURL tag:(NSInteger)tag
{
   if (downloadManagerDelegate_ && [downloadManagerDelegate_ respondsToSelector:@selector(downloadManagerDidFinishWithFileURL:tag:)]) {
      [downloadManagerDelegate_ downloadManagerDidFinishWithFileURL:fileURL tag:tag];
   }
}

- (void)broadcastDidFinishWithData:(NSData *)data tag:(NSInteger)tag
{
   if (downloadManagerDelegate_ && [downloadManagerDelegate_ respondsToSelector:@selector(downloadManagerDidFinishWithData:tag:)]) {
      [downloadManagerDelegate_ downloadManagerDidFinishWithData:data tag:tag];
   }
}


#pragma mark -
#pragma mark KTDownloaderDelegate Methods

- (void)downloader:(KTDownloader *)downloader didFinishWithData:(NSData *)data;
{
   NSString *key = [[downloader url] absoluteString];
   NSInteger tag = [downloader tag];
   KTDownloadManagerCaching caching = [downloader caching];

   data = [data retain];   // Thread runloop safety.
   
   // Release the downloader.
   [downloaderTable_ removeObject:downloader];
   [downloader release];
   
   // Cache the downloaded data.
   BOOL cacheToDisk = NO;
   BOOL cacheToMemory = NO;
   if ((caching & KTDownloadManagerCachingMemory) == KTDownloadManagerCachingMemory) {
      cacheToMemory = YES;
   }
   if ((caching & KTDownloadManagerCachingFileSystem) == KTDownloadManagerCachingFileSystem) {
      cacheToDisk = YES;
   }
   
   if (caching != KTDownloadManagerCachingNone) {
      KTFileCache *cache = [KTFileCache sharedKTFileCache];
      [cache storeData:data forKey:key toDisk:cacheToDisk toMemory:cacheToMemory];
   }
   
   if (caching == KTDownloadManagerCachingNone || cacheToMemory) {
      [self broadcastDidFinishWithData:data tag:tag];
   } else if (cacheToDisk) {
      KTFileCache *cache = [KTFileCache sharedKTFileCache];
      NSURL *fileURL = [cache fileURLWithKey:key];
      [self broadcastDidFinishWithFileURL:fileURL tag:tag];
   }
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
