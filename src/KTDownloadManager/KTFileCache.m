//
//  KTFileCache.m
//  KTDownloadManager
//
//  Created by Kirby Turner on 4/15/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//
//  The following code is inspired by and derived from SDWebImage.
//  http://github.com/rs/SDWebImage
//

#import "KTFileCache.h"
#import <CommonCrypto/CommonDigest.h>


static NSInteger cacheMaxCacheAge = 60*60*24*7; // 1 week


@interface KTFileCache (KTPrivateMethods)
- (NSString *)cachePathForKey:(NSString *)key;
- (void)storeData:(NSData *)data toDiskForKey:(NSString *)key;
- (NSString *)pathExtensionWithKey:(NSString *)key;
@end

@implementation KTFileCache

- (void)dealloc 
{
   [memoryCache_ release], memoryCache_ = nil;
   [diskCachePath_ release], diskCachePath_ = nil;
   [cacheInQueue_ release], cacheInQueue_ = nil;

   [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIApplicationDidReceiveMemoryWarningNotification  
                                                 object:nil];  
   
   [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIApplicationWillTerminateNotification  
                                                 object:nil];  
   
   if (&UIApplicationDidEnterBackgroundNotification) {
      [[NSNotificationCenter defaultCenter] removeObserver:self
                                                      name:UIApplicationDidEnterBackgroundNotification
                                                    object:nil];
   }
   
   [super dealloc];
}

- (id)init 
{
   self = [super init];
   if (self) {
      // Initial the memory cache.
      memoryCache_ = [[NSMutableDictionary alloc] init];
      
      // Initial the disk cache.
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
      diskCachePath_ = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"KTFileCache"] retain];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath_]) {
         [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath_ withIntermediateDirectories:YES attributes:nil error:NULL];
      }
      
      // Initial the operation queue.
      cacheInQueue_ = [[NSOperationQueue alloc] init];
      [cacheInQueue_ setMaxConcurrentOperationCount:2];
      
      // Subscribe to application events.
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(didReceiveMemoryWarning:)
                                                   name:UIApplicationDidReceiveMemoryWarningNotification  
                                                 object:nil];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(willTerminate)
                                                   name:UIApplicationWillTerminateNotification  
                                                 object:nil];       
      
      if (&UIApplicationDidEnterBackgroundNotification) {
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(willTerminate)
                                                      name:UIApplicationDidEnterBackgroundNotification
                                                    object:nil];
      }
   }
   return self;
}

#pragma mark -
#pragma mark Notification Handlers

- (void)didReceiveMemoryWarning:(void *)object
{
   [self clearMemory];
}

- (void)willTerminate
{
   [self cleanDisk];
}


#pragma mark -
#pragma mark Private methods

- (NSString *)cachePathForKey:(NSString *)key
{
   NSString *pathExtension = [self pathExtensionWithKey:key];
   const char *str = [key UTF8String];
   unsigned char r[CC_MD5_DIGEST_LENGTH];
   CC_MD5(str, strlen(str), r);
   NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                         r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];

   if (pathExtension) {
      filename = [filename stringByAppendingPathExtension:pathExtension];
   }
   
   return [diskCachePath_ stringByAppendingPathComponent:filename];
}

- (void)storeData:(NSData *)data toDiskForKey:(NSString *)key
{
   if (data != nil) {
      NSString *path = [self cachePathForKey:key];
      [[NSFileManager defaultManager] createFileAtPath:path 
                                              contents:data
                                            attributes:nil];
      [data release];
   }
}

- (NSString *)pathExtensionWithKey:(NSString *)key
{
   NSString *pathExt = nil;
   NSArray *components = [key componentsSeparatedByString:@"?"];
   if ([components count] > 0) {
      pathExt = [[components objectAtIndex:0] pathExtension];
   }
   return pathExt;
}


#pragma mark -
#pragma mark Public methods

- (void)storeData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk toMemory:(BOOL)toMemory
{
   if (nil == data || nil == key) {
      return;
   }
   
   if (toMemory) {
      [memoryCache_ setObject:data forKey:key];
   }
   
   if (toDisk) {
      [self storeData:data toDiskForKey:key];
      //      NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self 
      //                                                                    selector:@selector(storeKeyToDisk:)
      //                                                                      object:key];
      //      [cacheInQueue_ addOperation:operation];
      //      [operation release];
   }
}


- (NSData *)dataWithKey:(NSString *)key 
{
   if (nil == key) {
      return nil;
   }
   
   NSData *data = [memoryCache_ objectForKey:key];
   if (!data) {
      NSString *path = [self cachePathForKey:key];
      data = [NSData dataWithContentsOfFile:path];

      // Add to the memory cache.
      if (data != nil) {
         [memoryCache_ setObject:data forKey:key];
      }
   }

   return data;
}

- (NSURL *)fileURLWithKey:(NSString *)key
{
   if (nil == key) {
      return nil;
   }
   
   NSString *path = [self cachePathForKey:key];
   NSURL *url = nil;
   if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      url = [NSURL fileURLWithPath:path];
   }
   return url;
}

- (void)clearMemory 
{
   [cacheInQueue_ cancelAllOperations];
   [memoryCache_ removeAllObjects];
}

- (void)clearDisk
{
   [cacheInQueue_ cancelAllOperations];
   [[NSFileManager defaultManager] removeItemAtPath:diskCachePath_ error:nil];
   [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath_ withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)cleanDisk 
{
   NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
   NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:diskCachePath_];
   for (NSString *fileName in fileEnumerator) {
      NSString *filePath = [diskCachePath_ stringByAppendingPathComponent:fileName];
      NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
      if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate]) { 
         [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
      }
   }
}


#pragma mark -
#pragma mark Singleton Class Code

static KTFileCache *sharedKTFileCache = nil;

+ (KTFileCache *)sharedKTFileCache
{
	@synchronized(self)
	{ 
		if (sharedKTFileCache == nil) 
		{
			sharedKTFileCache = [[self alloc] init];
		} 
	} 
   
	return sharedKTFileCache;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (sharedKTFileCache == nil)
		{
			sharedKTFileCache = [super allocWithZone:zone];
			return sharedKTFileCache;
		} 
	} 
   
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}

- (void)release
{
}

- (id)autorelease
{
	return self;
}

@end
