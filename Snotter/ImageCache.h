//
//  ImageCache.h
//  LinePic
//
//  Created by 弘樹 松瀬 on 12/07/25.
//  Copyright (c) 2012年 beyond.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+ (ImageCache *)sharedInstance;
- (void)clearMemoryCache;
- (void)storeImage:(UIImage *)image URL:(NSString *)URL;
- (UIImage *)cachedImageWithURL:(NSString *)URL;

@end
