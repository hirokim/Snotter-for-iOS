//
//  GelandeManager.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/12/16.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gelande.h"

@interface GelandeManager : NSObject

@property (nonatomic) NSMutableArray *areaList;

+ (GelandeManager *)sharedInstance;

- (Gelande *)gelandeWithHashTag:(NSString *)hashTag;

@end
