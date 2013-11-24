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

////////////////////////////////////////
// for CPI

/**
 * @brief appCWebViewを表示する
 *
 */
+(void)openWebView;

/**
 * @brief appCMatchAppの利用を開始する
 *
 * @param delegate デリゲート
 */
+(void)matchAppStartWithDelegate:(id<appCMatchAppDelegate>)delegate;

/**
 * @brief appCMatchAppの利用を終了する
 *
 */
+(void)matchAppStop;

/**
 * @brief appCMatchAppのコントロールを登録する(UIButtonなど)
 *
 * @param control ボタン
 */
+(void)matchAppRegistWithControl:(UIControl *)control;

/**
 * @brief バナー広告表示
 *
 * @param vertical_ 垂直位置
 */
+ (BOOL)matchAppShowBannerWithHorizontal:(appCHorizontal)horizontal
                                vertical:(appCVertical)vertical;

/**
 * @brief バナー広告消去
 *
 */
+ (BOOL)matchAppHideBanner;

/**
 * @brief Cutin表示中を取得する
 *
 * @return YES:Cutin表示中
 */
+(BOOL)showingCutin;


////////////////////////////////////////
// for Gamsers

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
 * @return Nickname
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
 * @return プレー回数
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
 * @return LBデータ(JSON)
 */
+(NSString*)gamersGetLbWithId:(NSInteger)lb_id;

@end
