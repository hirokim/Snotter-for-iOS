//
//  TwitterManager.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "TwitterManager.h"

#define TwitterManagerSerialQueueName "TwitterManager.SerialQueue"

// アカウント取得時のブロック
typedef void (^fetchAccountHandler)(ACAccount *fetchAccount);

// 使用中アカウント保持用キー
NSString *const CURRENT_TWITTER_ID = @"CURRENT_TWITTER_ID";

@interface TwitterManager()
{
    ACAccountStore *accountStore;
    ACAccountType *accountType;
}
@end

@implementation TwitterManager

static TwitterManager* _sharedInstance = nil;
static dispatch_queue_t serialQueue;

/**
 * メモリ領域確保
 *
 * @return TwitterManagerインスタンス
 */
+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create(TwitterManagerSerialQueueName, NULL);
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
        }
    });
    return _sharedInstance;
}

/**
 * 初期化
 *
 * @return TwitterManagerインスタンス
 */
- (id)init {
    id __block obj;
    dispatch_sync(serialQueue, ^{
        obj = [super init];
        if (obj) {
            
            accountStore = [[ACAccountStore alloc] init];
            accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *twitterId = [ud objectForKey:CURRENT_TWITTER_ID];
            
            if (twitterId) {
                
                // 既にTwitterログインしている場合、そのアカウントを保持
                [self fetchAccountWithIdentifier:twitterId :^(ACAccount *fetchAccount) {
                    
                    self.usingAccount = fetchAccount;
                }];
            }
        }
    });
    self = obj;
    return self;
}

/**
 * インスタンス取得
 *
 * @return TwitterManagerインスタンス
 */
+ (TwitterManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TwitterManager alloc] init];
    });
    return _sharedInstance;
}

/**
 * ログイン
 *
 * @param viewController アカウントリストを表示するベースビュー
 */
- (void)logInWithShowInView:(UIViewController *)viewController
{
    TwitterAccountsViewController *ctl = [[TwitterAccountsViewController alloc] initWithAccount:self.usingAccount];
    ctl.delegate = self;
    
    [viewController presentViewController:ctl animated:YES completion:nil];
}

/**
 * アカウント取得
 *
 * @param identifier アカウントID
 * @param handler 取得後の動き
 */
- (void)fetchAccountWithIdentifier:(NSString *)identifier :(fetchAccountHandler)handler
{
    // Twitterの使用許可を得る
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        
        if (error) {
            DNSLog(error.localizedDescription);
        }
        
        ACAccount *tmpAccount = nil;
        if (granted) {
            
            // 既にログインしているなら、使用中アカウントを取得
            tmpAccount = [accountStore accountWithIdentifier:identifier];
        }
        
        handler(tmpAccount);
    }];
}

/**
 * アカウント選択された
 *
 * @param newAccount 選択された新しいアカウント
 */
- (void)didSelectedAccount:(ACAccount *)newAccount
{
    self.usingAccount = newAccount;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:self.usingAccount.identifier forKey:CURRENT_TWITTER_ID];
    [ud synchronize];
}

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
               Handler:(RequestHandler)handler
{
    [[NetworkActivityManager sharedInstance] increment];
    
    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                             parameters:params
                                          requestMethod:requestMethod];
    
    [request setAccount:self.usingAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        [[NetworkActivityManager sharedInstance] decrement];
        
        if (error) {
            DNSLog(error.description);
        }
        
        id jsonData = nil;
        if (responseData)
        {
            NSString *s = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            DNSLog(@"TwitterAPI responseData:\n %@", s);
            
            NSError *jsonError;
            jsonData = [NSJSONSerialization JSONObjectWithData:responseData
                                                       options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (jsonError) {
                
                DNSLog(jsonError.localizedDescription);
            }
            else if ([jsonData isKindOfClass:[NSDictionary class]] && [jsonData objectForKey:@"errors"]) {
                
                jsonData = nil;
            }
        }
        
        handler(jsonData, error);
    }];
}

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
                                  Handler:(RequestHandler)handler
{
    NSString *searchKeyword = [words componentsJoinedByString:@" OR "];
    
    DNSLog(@"Keyword:%@", searchKeyword);
    DNSLog(@"SinceID:%@", sinceId);
    DNSLog(@"MaxID:%@", maxId);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:searchKeyword forKey:@"q"];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:@"1" forKey:@"include_rts"];
    
    if (sinceId) {
        [params setObject:sinceId forKey:@"since_id"];
    }
    if (maxId) {
        [params setObject:maxId forKey:@"max_id"];
        [params setObject:@"10" forKey:@"count"];
    }
    else {
        [params setObject:@"10" forKey:@"count"];
    }
    
    [self requestWithURL:url parameters:params requestMethod:TWRequestMethodGET Handler:^(NSDictionary *searchResult, NSError *error) {
        
        NSArray *statuses = [searchResult objectForKey:@"statuses"];
        handler([self parseTimelineWithTimelineData:statuses], error);
    }];
}

/**
 * ユーザツイートリクエスト
 *
 * @param userId ユーザーID
 * @param sinceId 先頭ツイートID
 * @param maxId 末尾ツイートID
 * @param handler リクエスト結果受信時の処理
 */
- (void)requestUserStatusesWithUserID:(NSString *)userId
                               SinceID:(NSString *)sinceId
                                 MaxID:(NSString *)maxId
                               Handler:(RequestHandler)handler
{
    DNSLog(@"SinceID:%@", sinceId);
    DNSLog(@"MaxID:%@", maxId);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userId forKey:@"user_id"];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:@"1" forKey:@"include_rts"];
    
    if (sinceId) {
        [params setObject:sinceId forKey:@"since_id"];
    }
    if (maxId) {
        [params setObject:maxId forKey:@"max_id"];
        [params setObject:@"10" forKey:@"count"];
    }
    else {
        [params setObject:@"10" forKey:@"count"];
    }
    
    [self requestWithURL:url parameters:params requestMethod:TWRequestMethodGET Handler:^(NSArray *timeline, NSError *error) {
        
        handler([self parseTimelineWithTimelineData:timeline], error);
    }];
}

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
                               Handler:(RequestHandler)handler
{
    DNSLog(@"SinceID:%@", sinceId);
    DNSLog(@"MaxID:%@", maxId);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/statuses.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:listId forKey:@"list_id"];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:@"1" forKey:@"include_rts"];
    
    if (sinceId) {
        [params setObject:sinceId forKey:@"since_id"];
    }
    if (maxId) {
        [params setObject:maxId forKey:@"max_id"];
        [params setObject:@"10" forKey:@"count"];
    }
    else {
        [params setObject:@"10" forKey:@"count"];
    }
    
    [self requestWithURL:url parameters:params requestMethod:TWRequestMethodGET Handler:^(NSArray *timeline, NSError *error) {
        
        handler([self parseTimelineWithTimelineData:timeline], error);
    }];
}

/**
 * タイムラインパース
 *
 * @param timeline ツイート配列（JSONのstatuses部分）
 * @return TweetStatusの配列
 */
- (NSArray *)parseTimelineWithTimelineData:(NSArray *)timeline
{
    if (timeline == nil || timeline.count == 0) {
        return nil;
    }
    
    NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *tweetInfo in timeline) {
        
        TweetStatus *status = [[TweetStatus alloc] init];
        
        status.user = [self parseUserData:[tweetInfo objectForKey:@"user"]];
        
        status.status_id                     = [tweetInfo objectForKey:@"id_str"];
        status.text                          = [tweetInfo objectForKey:@"text"];
        status.created_at                    = [self dateFromCreatedAtDateString:[tweetInfo objectForKey:@"created_at"]];
    
        [statuses addObject:status];
    }
    
    return statuses;
}

/**
 * ユーザー情報パース
 *
 * @param user ユーザー情報（JSONのuser部分）
 * @return UserData
 */
- (UserData *)parseUserData:(NSDictionary *)user
{
    if (user == nil) {
        return nil;
    }
    
    UserData *data = [[UserData alloc] init];
    
    data.user_id                  = [user objectForKey:@"id_str"];
    data.screen_name              = [user objectForKey:@"screen_name"];
    data.name                     = [user objectForKey:@"name"];
    data.description              = [user objectForKey:@"description"];
    data.profile_image_url_https  = [user objectForKey:@"profile_image_url_https"];
    data.url                      = [user objectForKey:@"url"];
    data.statuses_count           = [[user objectForKey:@"statuses_count"] unsignedLongValue];
    data.followers_count          = [[user objectForKey:@"followers_count"] intValue];
    data.friends_count            = [[user objectForKey:@"friends_count"] intValue];
    
    if (![[user objectForKey:@"following"] isKindOfClass:[NSNull class]]) {
        data.following = [[user objectForKey:@"following"] boolValue];
    }
    
    return data;
}

/**
 * Twitter日付文字列をNSDateに変換
 *
 * @param strDate 日付文字列[EEE MMM dd HH:mm:ss Z yyyy]
 * @return NSDate
 */
- (NSDate*)dateFromCreatedAtDateString:(NSString*)strDate {

    static NSDateFormatter* format = nil;
    if (format == nil) {
        format = [[NSDateFormatter alloc] init];
        [format setDateStyle:NSDateFormatterLongStyle];
        [format setTimeStyle:NSDateFormatterNoStyle];
        [format setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
        [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    }
    return [format dateFromString:strDate];
}

/**
 * ユーザー情報取得
 *
 * @param userId ユーザーID
 * @param screenName スクリーン名
 * @param handler リクエスト結果受信時の処理
 */
- (void)requestUserInfoWithUserId:(NSString *)userId
                       ScreenName:(NSString *)screenName
                          Handler:(RequestHandler)handler
{
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/users/show.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userId forKey:@"user_id"];
    [params setObject:screenName forKey:@"screen_name"];
    
    [self requestWithURL:url parameters:params requestMethod:TWRequestMethodGET Handler:^(NSDictionary *user, NSError *error) {
        
        handler([self parseUserData:user], error);
    }];
}

@end
