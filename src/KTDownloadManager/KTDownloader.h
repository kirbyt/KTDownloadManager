//
//  KTDownloadManager.h
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTDownloadManager.h"

#define KTDownloaderErrorDomain @"KTDownloader Download Error Domain"

enum {
   KTDownloaderErrorNoConnection = 1000,
};

@interface KTDownloader : NSObject {
   NSURL *url_;
   NSInteger tag_;
   KTDownloadManagerResponseType responseType_;
@private
   KTDownloadManager *downloadManager_;
   NSMutableData *receivedData_;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) KTDownloadManagerResponseType responseType;

+ (KTDownloader *)newDownloaderWithURL:(NSURL *)url 
                                   tag:(NSInteger)tag 
                          responseType:(KTDownloadManagerResponseType)respType 
                       downloadManager:(KTDownloadManager *)downloadManager;

- (void)start;

@end
