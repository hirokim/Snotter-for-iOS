//
//  appC.h
//

#import <Foundation/Foundation.h>
#import "appCSimpleView.h"
#import "appCMoveIconView.h"
#import "appCMarqueeView.h"
#import "appCButtonView.h"
#import "appCCutinView.h"
#import "appCMatchAppDelegate.h"

/**
 * @brief appCのエントリクラス
 *
 */
@interface appC : NSObject

/**
 * @brief メディアキーを指定してappCを初期設定する
 *
 * @param mk_ メディアキー
 *
 */
+(void)setupAppCWithMediaKey:(NSString*)mk_;

/**
 * @brief appCWebViewを表示する
 *
 */
+(void)openWebView;

/**
 * @brief appCMatchAppの利用を開始する
 *
 */
+(void)matchAppStartWithDelegate:(id<appCMatchAppDelegate>)delegate;

/**
 * @brief appCMatchAppのコントロールを登録する(UIButtonなど)
 *
 */
+(void)matchAppRegistWithControl:(UIControl *)control;

/**
 * @brief Cutin表示中を取得する
 *
 * @return YES:Cutin表示中
 */
+(BOOL)showingCutin;

/**
 * @brief appC Gamers を表示する
 *
 */
+(BOOL)openGamers;

/**
 * @brief ゲーム開始
 *
 */
+(BOOL)gamersStartGame;

/**
 * @brief Nickname取得
 *
 */
+(NSString*)gamersGetNickname;

/**
 * @brief プレー回数加算
 *
 */
+(BOOL)gamersPlayCountIncrement;

/**
 * @brief プレー回数取得
 *
 */
+(NSInteger)gamersGetPlayCount;

/**
 * @brief LBスコア登録（整数）
 *
 * @param lb_id リーダーボードID
 * @param score スコア
 */
+(BOOL)gamersAddLbWithId:(NSInteger)lb_id
                  scorei:(NSInteger)score;

/**
 * @brief LBスコア登録（小数）
 *
 * @param lb_id リーダーボードID
 * @param score スコア
 */
+(BOOL)gamersAddLbWithId:(NSInteger)lb_id
                  scored:(CGFloat)score;

/**
 * @brief LBデータ取得(JSON)
 *
 * @param lb_id リーダーボードID
 */
+(NSString*)gamersGetLbWithId:(NSInteger)lb_id;

@end
