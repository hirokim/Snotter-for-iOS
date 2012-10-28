//
//  UIAsyncImageView.h
//  LinePic
//
//  Created by 弘樹 松瀬 on 12/07/24.
//  Copyright (c) 2012年 beyond.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAsyncImageView : UIImageView

@property (nonatomic, readonly) NSString *imageURL;

-(void)loadImageWithURL:(NSString *)url;
-(void)abort;

@end
