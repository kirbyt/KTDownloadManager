//
//  KTFileCache.h
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KTFileCache : NSObject {
   NSMutableDictionary *memoryCache_;
   NSString *diskCachePath_;
   NSOperationQueue *cacheInQueue_;
}

+ (KTFileCache *)sharedKTFileCache;
- (void)storeData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk toMemory:(BOOL)toMemory;
- (NSData *)dataWithKey:(NSString *)key;
- (NSURL *)fileURLWithKey:(NSString *)key;
- (void)clearMemory;
- (void)clearDisk;
- (void)cleanDisk;


@end
