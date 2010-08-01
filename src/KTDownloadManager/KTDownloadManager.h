//
//  KTDownloadManager.h
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTDownloaderDelegate.h"
#import "KTDownloadManagerDelegate.h"

enum {
   KTDownloadManagerCachingNone             = 0,
   KTDownloadManagerCachingMemory           = 1 << 0,
   KTDownloadManagerCachingFileSystem       = 1 << 1
};
typedef NSUInteger KTDownloadManagerCaching;

@class KTDownloader;

@interface KTDownloadManager : NSObject <KTDownloaderDelegate> {
   id<KTDownloadManagerDelegate> downloadManagerDelegate_;
@private
   NSMutableSet *downloaderTable_;
}

@property (nonatomic, assign) id<KTDownloadManagerDelegate> delegate;

- (void)downloadDataWithURL:(NSURL *)url tag:(NSInteger)tag caching:(KTDownloadManagerCaching)caching;

/**
 * Returns the data downloaded from the URL. This should ONLY be called
 * after the data has been downloaded.
 */
- (NSData *)dataWithURL:(NSURL *)url;

@end
