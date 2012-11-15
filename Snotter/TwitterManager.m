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
 */
- (void)requestWithURL:(NSURL *)url parameters:(NSDictionary *)params requestMethod:(TWRequestMethod)requestMethod Handler:(RequestHandler)handler
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
        
        handler(jsonData);
    }];
}

/**
 * サーチリクエスト
 *
 */
- (void)requestSearchStatusesWithKeywords:(NSArray *)words SinceID:(NSString *)sinceId MaxID:(NSString *)maxId Handler:(RequestHandler)handler
{
    NSString *searchKeyword = [words componentsJoinedByString:@"+OR+"];
    
    DNSLog(@"Keyword:%@", searchKeyword);
    DNSLog(@"SinceID:%@", sinceId);
    DNSLog(@"MaxID:%@", maxId);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:searchKeyword forKey:@"q"];
    [params setObject:@"10" forKey:@"count"];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:@"1" forKey:@"include_rts"];
    if (sinceId)    [params setObject:sinceId forKey:@"since_id"];
    if (maxId)      [params setObject:maxId forKey:@"max_id"];
    
    [self requestWithURL:url parameters:params requestMethod:TWRequestMethodGET Handler:^(NSDictionary *searchResult) {
        
        NSArray *statuses = [searchResult objectForKey:@"statuses"];
        handler([self parseTimelineWithTimelineData:statuses]);
    }];
}

/**
 * リストリクエスト
 *
 */
- (void)requestListsStatusesWithListID:(NSString *)listId SinceID:(NSString *)sinceId MaxID:(NSString *)maxId Handler:(RequestHandler)handler
{
    DNSLog(@"SinceID:%@", sinceId);
    DNSLog(@"MaxID:%@", maxId);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/lists/statuses.json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:listId forKey:@"list_id"];
    [params setObject:@"10" forKey:@"count"];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:@"1" forKey:@"include_rts"];
    if (sinceId)    [params setObject:sinceId forKey:@"since_id"];
    if (maxId)      [params setObject:maxId forKey:@"max_id"];
    
    [self requestWithURL:url parameters:params requestMethod:TWRequestMethodGET Handler:^(NSArray *timeline) {
        
        handler([self parseTimelineWithTimelineData:timeline]);
    }];
}

/**
 * タイムラインパース
 *
 */
- (NSArray *)parseTimelineWithTimelineData:(NSArray *)timeline
{
    if (timeline == nil || timeline.count == 0) {
        return nil;
    }
    
    NSMutableArray *statuses = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *tweetInfo in timeline) {
        
        NSDictionary *userData = [tweetInfo objectForKey:@"user"];
        
        TweetStatus *status             = [[TweetStatus alloc] init];
        status.status_id                = [tweetInfo objectForKey:@"id_str"];
        status.user_id                  = [userData objectForKey:@"id_str"];
        status.screen_name              = [userData objectForKey:@"screen_name"];
        status.name                     = [userData objectForKey:@"name"];
        status.description              = [userData objectForKey:@"description"];
        status.profile_image_url_https  = [userData objectForKey:@"profile_image_url_https"];
        status.url                      = [userData objectForKey:@"url"];
        status.statuses_count           = [[userData objectForKey:@"statuses_count"] unsignedLongValue];
        status.followers_count          = [[userData objectForKey:@"followers_count"] intValue];
        status.friends_count            = [[userData objectForKey:@"friends_count"] intValue];
        status.text                     = [tweetInfo objectForKey:@"text"];
        status.date                     = [self dateFromCreatedAtDateString:[tweetInfo objectForKey:@"created_at"]];
        
        [statuses addObject:status];
    }
    
    return statuses;
}

/**
 * 日付文字列をNSDateに変換
 *
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

@end
