//
//  MyDownloadManager.h
//  Sample
//
//  Created by Kirby Turner on 8/2/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTDownloadManagerDelegate.h"

@class KTDownloadManager;
@protocol MyDownloadManagerDelegate;

@interface MyDownloadManager : NSObject <KTDownloadManagerDelegate> {
   KTDownloadManager *dm;
   id<MyDownloadManagerDelegate> delegate;
}

@property (nonatomic, retain) id<MyDownloadManagerDelegate> delegate;

- (void)downloadImageWithURL:(NSURL *)url;
- (void)downloadAudioFileWithURL:(NSURL *)url;

@end


@protocol MyDownloadManagerDelegate <NSObject>
@optional
- (void)myDownloadManagerImage:(UIImage *)image;
- (void)myDownloadManagerAudioFileURL:(NSURL *)url;
- (void)myDownloadManagerDidFailWithError:(NSError *)error;
@end