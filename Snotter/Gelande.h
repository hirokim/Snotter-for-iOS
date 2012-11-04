//
//  Gelande.h
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Gelande : NSObject <MKAnnotation, NSCoding>

@property (nonatomic) NSString *hashTag;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *longitude;
@property (nonatomic) NSString *telNumber;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *largeAreaName;
@property (nonatomic) NSString *smallAreaName;
@property (nonatomic) NSString *csvFileName;
@property (nonatomic) NSString *kana;

@end
