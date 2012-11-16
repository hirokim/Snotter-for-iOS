//
//  ImageCache.m
//  LinePic
//
//  Created by 弘樹 松瀬 on 12/07/25.
//  Copyright (c) 2012年 beyond.inc. All rights reserved.
//

#import "ImageCache.h"
#import <CommonCrypto/CommonHMAC.h>

@interface ImageCache()
{
     NSCache *cache;
}
@end

@implementation ImageCache

/**
 * ImageCacheインスタンス取得
 *
 */
+ (ImageCache *)sharedInstance
{
    static ImageCache *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        sharedInstance = [[ImageCache alloc] init];
    });
    
    return sharedInstance;
}

/**
 * ImageCacheインスタンス初期化
 *
 */
- (id)init
{
    self = [super init];
    if (self) 
    {
        // メモリワーニングをキャッチ
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification 
                                                   object:nil];
        
        // キャッシュ領域作成
        cache = [[NSCache alloc] init];
        cache.countLimit = 1000;
    }
    
    return self;
}

/**
 * メモリー警告発生時
 *
 */
- (void)didReceiveMemoryWarning:(NSNotification *)notif
{
    [self clearMemoryCache];
}

/**
 * インスタンス破棄
 *
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    cache = nil;
}

#pragma mark -

/**
 * キャッシュクリア
 *
 */
- (void)clearMemoryCache
{
    [cache removeAllObjects];
}

/**
 * 画像をキャッシュに保存
 *
 */
- (void)storeImage:(UIImage *)image URL:(NSString *)URL 
{
    NSString *key = [ImageCache keyForURL:URL];
    [cache setObject:image forKey:key];
}

/**
 * URLからキャッシュ時のキーを取得（MD5値）
 *
 */
+ (NSString *)keyForURL:(NSString *)URL 
{
	if ([URL length] == 0) 
    {
		return nil;
	}
    
	const char *cStr = [URL UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]]; 	
}

/**
 * キャッシュから画像取得
 *
 */
- (UIImage *)cachedImageWithURL:(NSString *)URL 
{
    NSString *key = [ImageCache keyForURL:URL];
    UIImage *cachedImage = [cache objectForKey:key];
    if (!cachedImage) 
    {
        return nil;
    }
    
    return cachedImage;
}

@end
