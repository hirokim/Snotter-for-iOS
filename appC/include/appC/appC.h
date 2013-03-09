//
//  appC.h
//

#import <Foundation/Foundation.h>
#import "appCSimpleView.h"
#import "appCMarqueeView.h"
#import "appCButtonView.h"

@interface appC : NSObject

//	メディアキーを指定してappCを初期設定します
+(void)setupAppCWithMediaKey:(NSString*)_mk;

@end
