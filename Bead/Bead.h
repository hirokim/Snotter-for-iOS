//
//  Bead.h
//  Bead
//
//  Ver 1.0.0
//
//  Copyright (c) 2012年 beyond.inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Bead : NSObject

/**
 * 初期化
 *
 */
+ (void)initializeAd;

/**
 * Beadインスタンス取得
 *
 */
+ (Bead *)sharedInstance;

/**
 * 広告の追加
 *
 * @param sid 広告ID
 */
- (void)addSID:(NSString *)sid;

/**
 * 広告の追加
 *
 * @param sid 広告ID
 * @param interval 広告表示インターバル
 */
- (void)addSID:(NSString *)sid interval:(int)interval;

/**
 * 広告ダイアログの表示
 *
 * @param sid 広告ID
 */
- (BOOL)showWithSID:(NSString *)sid;

@end