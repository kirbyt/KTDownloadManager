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

extern NSString * const ktDownloadManagerResponseKeyData;
extern NSString * const ktDownloadManagerResponseKeyFileURL;


enum {
   KTDownloadManagerResponseTypeNone      = 0,
   KTDownloadManagerResponseTypeData      = 1 << 0,
   KTDownloadManagerResponseTypeFileURL   = 1 << 1
};
typedef NSUInteger KTDownloadManagerResponseType;

@class KTDownloader;

@interface KTDownloadManager : NSObject <KTDownloaderDelegate> {
   id<KTDownloadManagerDelegate> downloadManagerDelegate_;
@private
   NSMutableSet *downloaderTable_;
}

@property (nonatomic, assign) id<KTDownloadManagerDelegate> delegate;

- (void)downloadDataWithURL:(NSURL *)url tag:(NSInteger)tag responseType:(KTDownloadManagerResponseType)respType;

/**
 * Returns the data downloaded from the URL. This should ONLY be called
 * after the data has been downloaded.
 */
- (NSData *)dataWithURL:(NSURL *)url;

@end
