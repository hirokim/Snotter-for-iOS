//
//  TwitterManager.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TwitterAccountsViewController.h"
#import "TweetStatus.h"

typedef void (^RequestHandler)(id, NSError *error);

@interface TwitterManager : NSObject <TwitterAccountsViewControllerDelegate>

@property (nonatomic) ACAccount *usingAccount;

/**
 * インスタンス取得
 *
 * @return TwitterManagerインスタンス
 */
+ (TwitterManager*)sharedInstance;

/**
 * ログイン
 *
 * @param viewController アカウントリストを表示するベースビュー
 */
- (void)logInWithShowInView:(UIViewController *)viewController;

/**
 * TwitterAPIにリクエスト
 *
 * @param url TwitterAPIリクエストURL
 * @param params パラメータ
 * @param requestMethod GET/POST
 * @param handler リクエスト結果受信時の処理
 */
- (void)requestWithURL:(NSURL *)url
            parameters:(NSDictionary *)params
         requestMethod:(TWRequestMethod)requestMethod
               Handler:(RequestHandler)handler;

/**
 * リストリクエスト
 *
 * @param listId リストID
 * @param sinceId 先頭ツイートID
 * @param maxId 末尾ツイートID
 * @param handler リクエスト結果受信時の処理
 */
- (void)requestListsStatusesWithListID:(NSString *)listId
                               SinceID:(NSString *)sinceId
                                 MaxID:(NSString *)maxId
                               Handler:(RequestHandler)handler;

/**
 * サーチリクエスト
 *
 * @param words 検索ワード配列
 * @param sinceId 先頭ツイートID
 * @param maxId 末尾ツイートID
 * @param handler リクエスト結果受信時の処理
 */
- (void)requestSearchStatusesWithKeywords:(NSArray *)words
                                  SinceID:(NSString *)sinceId
                                    MaxID:(NSString *)maxId
                                  Handler:(RequestHandler)handler;

@end
