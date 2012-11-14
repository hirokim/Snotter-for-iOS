//
//  UIAsyncImageView.m
//  LinePic
//
//  Created by 弘樹 松瀬 on 12/07/24.
//  Copyright (c) 2012年 beyond.inc. All rights reserved.
//

#import "UIAsyncImageView.h"
#import "ImageCache.h"

@interface UIAsyncImageView()
{
    NSURLConnection *connection;
    NSMutableData *data;
    BOOL isErr;
    
    UIActivityIndicatorView *indicator;
}

@end

@implementation UIAsyncImageView

/**
 * 初期化
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        indicator.center = self.center;
        indicator.hidden = YES;
        [self addSubview:indicator];
        
        self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

/**
 * 画像ロード
 */
- (void)loadImageWithURL:(NSString *)url
{
    [self abort];
    _imageURL = url;
    
    UIImage *cachedImage = [[ImageCache sharedInstance] cachedImageWithURL:self.imageURL];
    if (cachedImage)
    {
        // キャッシュにある場合はそれをセット
        self.image = cachedImage;
        [self stopIndicator];
        return;
    }
    
    [self startIndicator];
    
    data = [[NSMutableData alloc] initWithCapacity:0];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:60.0];

    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

/**
 * レスポンス受信
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data setLength:0];
    
    int statusCode = [((NSHTTPURLResponse *)response) statusCode];  
    if(statusCode >= 400)
    {  
        //エラーハンドリング
        isErr = YES;
    }
}

/**
 * データ受信中
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata
{
    [data appendData:nsdata];
}

/**
 * エラー発生
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopIndicator];
    [self abort];
}

/**
 * データ受信完了
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self stopIndicator];
        
        if (isErr == NO)
        {
            self.image = [UIImage imageWithData:data];
            
            // キャッシュ
            [[ImageCache sharedInstance] storeImage:self.image URL:self.imageURL];
        }
        
        [self abort];
    });
}

/**
 * クリア
 */
- (void)abort
{
    [connection cancel];
    connection = nil;
    data = nil;
    isErr = NO;
}

/**
 * インスタンス破棄
 */
- (void)dealloc 
{
    indicator = nil;
    [self abort];
}

/**
 * インジケータ開始
 */
- (void)startIndicator
{
    [[NetworkActivityManager sharedInstance] increment];
    [indicator startAnimating];
    indicator.hidden = NO;
}

/**
 * インジケータ終了
 */
- (void)stopIndicator
{
    [[NetworkActivityManager sharedInstance] decrement];
    [indicator stopAnimating];
    indicator.hidden = YES;
}

@end
