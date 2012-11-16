//
//  Gelande.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/11/04.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "Gelande.h"

#define GELANDE_HASH_TAG        @"GELANDE_HASH_TAG"
#define GELANDE_NAME            @"GELANDE_NAME"
#define GELANDE_LATITUDE        @"GELANDE_LATITUDE"
#define GELANDE_LONGITUDE       @"GELANDE_LONGITUDE"
#define GELANDE_TEL_LNUMBER     @"GELANDE_TEL_LNUMBER"
#define GELANDE_ADDRESS         @"GELANDE_ADDRESS"
#define GELANDE_LARGE_AREA_NAME @"GELANDE_LARGE_AREA_NAME"
#define GELANDE_SMALL_AREA_NAME @"GELANDE_SMALL_AREA_NAME"
#define GELANDE_CSV_FILE_NAME   @"GELANDE_CSV_FILE_NAME"
#define GELANDE_KANA            @"GELANDE_KANA"
#define GELANDE_SEARCH_WORD     @"GELANDE_SEARCH_WORD"

@implementation Gelande

/*
 地図のアノテーションの位置
 */
- (CLLocationCoordinate2D)coordinate {
	
	CLLocationCoordinate2D coordinate;
	// 緯度指定
	coordinate.latitude = [self.latitude doubleValue];
	// 経度指定
	coordinate.longitude = [self.longitude doubleValue];
	
	return coordinate;
}

/*
 地図のアノテーションのタイトル
 */
- (NSString *)title {
	return self.name;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    
    [coder encodeObject:self.hashTag forKey:GELANDE_HASH_TAG];
    [coder encodeObject:self.name forKey:GELANDE_NAME];
    [coder encodeObject:self.latitude forKey:GELANDE_LATITUDE];
    [coder encodeObject:self.longitude forKey:GELANDE_LONGITUDE];
    [coder encodeObject:self.telNumber forKey:GELANDE_TEL_LNUMBER];
    [coder encodeObject:self.address forKey:GELANDE_ADDRESS];
    [coder encodeObject:self.largeAreaName forKey:GELANDE_LARGE_AREA_NAME];
    [coder encodeObject:self.smallAreaName forKey:GELANDE_SMALL_AREA_NAME];
    [coder encodeObject:self.csvFileName forKey:GELANDE_CSV_FILE_NAME];
    [coder encodeObject:self.kana forKey:GELANDE_KANA];
    [coder encodeObject:self.serachWord forKey:GELANDE_SEARCH_WORD];
}

- (id)initWithCoder:(NSCoder*)coder {
    if ( (self = [super init]) ) {
        
        self.hashTag = [coder decodeObjectForKey:GELANDE_HASH_TAG];
        self.name = [coder decodeObjectForKey:GELANDE_NAME];
        self.latitude = [coder decodeObjectForKey:GELANDE_LATITUDE];
        self.longitude = [coder decodeObjectForKey:GELANDE_LONGITUDE];
        self.telNumber = [coder decodeObjectForKey:GELANDE_TEL_LNUMBER];
        self.address = [coder decodeObjectForKey:GELANDE_ADDRESS];
        self.largeAreaName = [coder decodeObjectForKey:GELANDE_LARGE_AREA_NAME];
        self.smallAreaName = [coder decodeObjectForKey:GELANDE_SMALL_AREA_NAME];
        self.csvFileName = [coder decodeObjectForKey:GELANDE_CSV_FILE_NAME];
        self.kana = [coder decodeObjectForKey:GELANDE_KANA];
        self.serachWord = [coder decodeObjectForKey:GELANDE_SEARCH_WORD];
    }
    return self;
}

@end
