#import <Foundation/Foundation.h>

@interface NetworkActivityManager : NSObject {
    
    NSUInteger activityCount;
}

+ (NetworkActivityManager *)sharedInstance;

- (void)increment;
- (void)decrement;
- (BOOL)isLoading;

@end