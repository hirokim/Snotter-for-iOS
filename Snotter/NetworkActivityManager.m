#import "NetworkActivityManager.h"


#define NetworkActivityManagerSerialQueueName "NetworkActivityManager.SerialQueue"

@implementation NetworkActivityManager

static NetworkActivityManager*  _sharedInstance = nil;
static dispatch_queue_t serialQueue;

/**
 * メモリ領域確保
 *
 */
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        serialQueue = dispatch_queue_create(NetworkActivityManagerSerialQueueName, NULL);
        
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
- (id)init
{
    id __block obj;
    dispatch_sync(serialQueue, ^{
        
        obj = [super init];
        if (obj) {
            
            activityCount = 0;
        }
    });
    
    self = obj;
    return self;
}

/**
 * インスタンス取得
 *
 */
+ (NetworkActivityManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[NetworkActivityManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)increment
{
    if(activityCount == 0) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    activityCount++;
    
    DNSLog(@"NetworkActivityManager ++, %d", activityCount);
}

- (void)decrement
{
    if(activityCount > 0) {
        activityCount--;
        
        if(activityCount == 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
        DNSLog(@"NetworkActivityManager --, %d", activityCount);
    }
}

- (BOOL)isLoading
{
    if (activityCount > 0) {
        return YES;
    }
    return NO;
}

@end