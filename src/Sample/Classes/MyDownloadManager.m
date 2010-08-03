//
//  MyDownloadManager.m
//  Sample
//
//  Created by Kirby Turner on 8/2/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "MyDownloadManager.h"
#import "KTDownloadManager.h"


#define DOWNLOADTYPE_IMAGE 1
#define DOWNLOADTYPE_AUDIO 2


@implementation MyDownloadManager

@synthesize delegate;

- (void)dealloc
{
   [dm release], dm = nil;
   
   [super dealloc];
}

- (id)init
{
   self = [super init];
   if (self) {
      dm = [[KTDownloadManager alloc] init];
      [dm setDelegate:self];
   }
   return self;
}

- (void)downloadImageWithURL:(NSURL *)url
{
   [dm downloadDataWithURL:url tag:DOWNLOADTYPE_IMAGE responseType:KTDownloadManagerResponseTypeData|KTDownloadManagerResponseTypeFileURL];
}

- (void)downloadAudioFileWithURL:(NSURL *)url
{
   [dm downloadDataWithURL:url tag:DOWNLOADTYPE_AUDIO responseType:KTDownloadManagerResponseTypeFileURL];
}

#pragma mark -
#pragma mark KTDownloadManagerDelegate Methods

- (void)downloadManagerDidFinishWithResponseData:(NSDictionary *)respData tag:(NSInteger)tag
{
   if (tag == DOWNLOADTYPE_IMAGE) {
      if (delegate && [delegate respondsToSelector:@selector(myDownloadManagerImage:)]) {
         NSData *data = [respData objectForKey:ktDownloadManagerResponseKeyData];
         UIImage *image = [UIImage imageWithData:data];
         [delegate myDownloadManagerImage:image];
      }
   } else if (tag == DOWNLOADTYPE_AUDIO) {
      if (delegate && [delegate respondsToSelector:@selector(myDownloadManagerAudioFileURL:)]) {
         NSURL *url = [respData objectForKey:ktDownloadManagerResponseKeyFileURL];
         [delegate myDownloadManagerAudioFileURL:url];
      }
   }
}

- (void)downloadManagerDidFailWithError:(NSError *)error
{
   if (delegate && [delegate respondsToSelector:@selector(myDownloadManagerDidFailWithError:)]) {
      [delegate myDownloadManagerDidFailWithError:error];
   }
}

@end
