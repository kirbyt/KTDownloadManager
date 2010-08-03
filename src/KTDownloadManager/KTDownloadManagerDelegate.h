//
//  KTDownloadManagerDelegate.h
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTDownloader;

@protocol KTDownloadManagerDelegate <NSObject>

@optional
- (void)downloadManagerDidFinishWithResponseData:(NSDictionary *)respData tag:(NSInteger)tag;
- (void)downloadManagerDidFailWithError:(NSError *)error;

@end
