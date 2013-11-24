//
//  main.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/21.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        @try{
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }@catch (NSException *exception) {
            NSLog(@"落ちた箇所:%@",  [exception callStackSymbols]);
            NSLog(@"落ちた原因:%@", exception);
        }
    }
}
