//
//  KTDownloaderDelegate.h
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTDownloader;

@protocol KTDownloaderDelegate <NSObject>
@required
- (void)downloader:(KTDownloader *)downloader didFinishWithData:(NSData *)data;
- (void)downloader:(KTDownloader *)downloader didFailWithError:(NSError *)error;

@end
