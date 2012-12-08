//
//  UIFollowButton.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/12/08.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "UIFollowButton.h"

@implementation UIFollowButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setHighlighted:(BOOL)value
{
    [super setHighlighted:value];
    [self setNeedsDisplay];
}

-(void)setSelected:(BOOL)value
{
    [super setSelected:value];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // -------------------------------------------
    //
    // コンテキストの状態を設定
    //
    // -------------------------------------------
    // 現在のコンテキストを取得してスタックしておく
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
        
    // 角丸のパスを取得してコンテキストに追加
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    CGContextAddPath(context, path.CGPath);
    
    // 角丸パスでクリップする（クリップした範囲のみにグラデーションがかかる）
    [path addClip];
    
    
    // -------------------------------------------
    //
    // グラデーション処理
    //
    // -------------------------------------------
    // カラースペースを取得
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    // カラー設定
    CGFloat components[16];
    if (self.state == UIControlStateHighlighted) {
        
        CGFloat componentsTmp[] = {
            0.502f, 0.663f, 0.388f, 0.8f,     // R, G, B, Alpha
            0.153f, 0.306f, 0.102f, 0.8f,
            0.098f, 0.227f, 0.047f, 0.8f,
            0.263f, 0.502f, 0.059f, 0.8f
        };
        
        memcpy(components, componentsTmp, sizeof(componentsTmp));
    }
    else {
        
        CGFloat componentsTmp[] = {
            0.659f, 0.769f, 0.580f, 1.0f,     // R, G, B, Alpha
            0.267f, 0.529f, 0.176f, 1.0f,
            0.204f, 0.475f, 0.094f, 1.0f,
            0.404f, 0.773f, 0.090f, 1.0f
        };
        
        memcpy(components, componentsTmp, sizeof(componentsTmp));
    }
    
    // 各色毎のグラデーションの割合 0.0 〜 1.0
    // 例：{ 0.0f, 1.0f }　だと片端が１つ目の色、もう片端が２つ目の色。全体にグラデーションがかかる。
    // 例：{ 0.3f, 0.7f }　だと始めの３０％までが１つ目の色、７０％以降が２つ目の色。その間４０％にグラデーションがかかる。
    CGFloat locations[] = { 0.0f, 0.5f, 0.5, 1.0 };
    
    // 色の数
    size_t count = sizeof(components) / (sizeof(CGFloat)* 4);
    
    // グラデーション情報生成
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    // グラデーションの対象となる開始位置と終了位置
    CGRect frame = self.bounds;
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    
    // グラデーションを行う
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    // 後始末
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    
    // -------------------------------------------
    //
    // コンテキストの状態を元に戻す
    //
    // -------------------------------------------
    CGContextRestoreGState(context);
}

@end
