//
//  GelandeManager.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/12/16.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "GelandeManager.h"

#define GelandeManagerSerialQueueName "GelandeManager.SerialQueue"

@implementation GelandeManager

static GelandeManager*  _sharedInstance = nil;
static dispatch_queue_t serialQueue;

/**
 * メモリ領域確保
 *
 */
+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        serialQueue = dispatch_queue_create(GelandeManagerSerialQueueName, NULL);
        
        if (_sharedInstance == nil) {
            
            _sharedInstance = [super allocWithZone:zone];
        }
    });
    
    return _sharedInstance;
}

/**
 * 初期化
 *
 */
- (id)init
{
    id __block obj;
    dispatch_sync(serialQueue, ^{
        
        obj = [super init];
        if (obj) {
            [self createAllGelandeList];
        }
    });
    
    self = obj;
    return self;
}

/**
 * インスタンス取得
 *
 */
+ (GelandeManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[GelandeManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)createAllGelandeList
{
    self.areaList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray *gelandeList = nil;
    NSString *largeAreaName = nil;
    
    largeAreaName = @"北海道";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"douhoku" LargeAreaName:largeAreaName SmallAreaName:@"道北"]];
	[gelandeList addObject:[self loadGelandeCSV:@"doutou" LargeAreaName:largeAreaName SmallAreaName:@"道東"]];
	[gelandeList addObject:[self loadGelandeCSV:@"douou" LargeAreaName:largeAreaName SmallAreaName:@"道央"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"東北";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"aomori" LargeAreaName:largeAreaName SmallAreaName:@"青森"]];
	[gelandeList addObject:[self loadGelandeCSV:@"iwate" LargeAreaName:largeAreaName SmallAreaName:@"岩手"]];
	[gelandeList addObject:[self loadGelandeCSV:@"akita" LargeAreaName:largeAreaName SmallAreaName:@"秋田"]];
	[gelandeList addObject:[self loadGelandeCSV:@"miyagi" LargeAreaName:largeAreaName SmallAreaName:@"宮城"]];
	[gelandeList addObject:[self loadGelandeCSV:@"yamagata" LargeAreaName:largeAreaName SmallAreaName:@"山形"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hukushima" LargeAreaName:largeAreaName SmallAreaName:@"福島"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"関東甲信越";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"nasu" LargeAreaName:largeAreaName SmallAreaName:@"那須・塩原"]];
	[gelandeList addObject:[self loadGelandeCSV:@"numata" LargeAreaName:largeAreaName SmallAreaName:@"沼田・水上"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kusatsu" LargeAreaName:largeAreaName SmallAreaName:@"草津・嬬恋・万座"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kanagawa" LargeAreaName:largeAreaName SmallAreaName:@"神奈川・埼玉"]];
	[gelandeList addObject:[self loadGelandeCSV:@"jouetsu" LargeAreaName:largeAreaName SmallAreaName:@"上越・湯沢"]];
	[gelandeList addObject:[self loadGelandeCSV:@"myoukou" LargeAreaName:largeAreaName SmallAreaName:@"妙高"]];
	[gelandeList addObject:[self loadGelandeCSV:@"madarao" LargeAreaName:largeAreaName SmallAreaName:@"斑尾・野沢・飯綱"]];
	[gelandeList addObject:[self loadGelandeCSV:@"fuji" LargeAreaName:largeAreaName SmallAreaName:@"富士・八ヶ岳・車山"]];
	[gelandeList addObject:[self loadGelandeCSV:@"karuizawa" LargeAreaName:largeAreaName SmallAreaName:@"軽井沢・菅平"]];
	[gelandeList addObject:[self loadGelandeCSV:@"shigakougen" LargeAreaName:largeAreaName SmallAreaName:@"志賀高原・北志賀"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hakuba" LargeAreaName:largeAreaName SmallAreaName:@"白馬"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"北陸";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"toyama" LargeAreaName:largeAreaName SmallAreaName:@"富山"]];
	[gelandeList addObject:[self loadGelandeCSV:@"ishikawa" LargeAreaName:largeAreaName SmallAreaName:@"石川"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hukui" LargeAreaName:largeAreaName SmallAreaName:@"福井"]];
    [self.areaList addObject:gelandeList];
    
    largeAreaName = @"中京";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"hida" LargeAreaName:largeAreaName SmallAreaName:@"御岳・飛騨・奥美濃"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"関西";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"shiga" LargeAreaName:largeAreaName SmallAreaName:@"滋賀"]];
	[gelandeList addObject:[self loadGelandeCSV:@"hyougo" LargeAreaName:largeAreaName SmallAreaName:@"兵庫"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kyoto" LargeAreaName:largeAreaName SmallAreaName:@"京都・三重"]];
    [self.areaList addObject:gelandeList];
    
    
    largeAreaName = @"中国・四国・九州";
    gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    [gelandeList addObject:[self loadGelandeCSV:@"tottori" LargeAreaName:largeAreaName SmallAreaName:@"鳥取・島根"]];
	[gelandeList addObject:[self loadGelandeCSV:@"okayama" LargeAreaName:largeAreaName SmallAreaName:@"岡山・広島・山口"]];
	[gelandeList addObject:[self loadGelandeCSV:@"shikoku" LargeAreaName:largeAreaName SmallAreaName:@"四国"]];
	[gelandeList addObject:[self loadGelandeCSV:@"kyushu" LargeAreaName:largeAreaName SmallAreaName:@"九州"]];
    [self.areaList addObject:gelandeList];
}

- (NSMutableArray *)loadGelandeCSV:(NSString *)fileName LargeAreaName:(NSString *)largeName SmallAreaName:(NSString *)smallName
{
    // CSVファイル読み込み
	NSString *csvFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"csv"];
	NSData *csvData = [NSData dataWithContentsOfFile:csvFile];
	NSString *csv = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
	NSScanner *scanner = [NSScanner scannerWithString:csv];
	
	// 改行文字の集合を取得
	NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
    
	// 一行ずつの読み込み
	NSString *line;
	NSMutableArray *gelandeList = [[NSMutableArray alloc] initWithCapacity:0];
    
	while (![scanner isAtEnd]) {
        
		// 一行読み込み
		[scanner scanUpToCharactersFromSet:chSet intoString:&line];
		
		// カンマ「,」で区切る
		NSArray *array = [line componentsSeparatedByString:@","];
        
		// ゲレンデ情報を配列に挿入する
		Gelande *g = [[Gelande alloc] init];
		
		g.name = [array objectAtIndex:0];
		g.address = [array objectAtIndex:1];
		g.telNumber = [array objectAtIndex:2];
		g.hashTag = [NSString stringWithFormat:@"#%@", [array objectAtIndex:3]];
		g.latitude = [array objectAtIndex:4];
		g.longitude = [array objectAtIndex:5];
        g.largeAreaName = largeName;
		g.smallAreaName = smallName;
		g.csvFileName = fileName;
		g.kana = [array objectAtIndex:6];
		g.serachWord = [array objectAtIndex:7];
        
		[gelandeList addObject:g];
		
		//　改行文字をスキップ
		[scanner scanCharactersFromSet:chSet intoString:NULL];
	}
    
    return gelandeList;
}

- (Gelande *)gelandeWithHashTag:(NSString *)hashTag
{
    for (NSArray *arealist in self.areaList) {
        for (NSArray *gelandeList in arealist) {
            for (Gelande *gelande in gelandeList) {
                
                if ([gelande.hashTag isEqualToString:hashTag]) {
                    
                    return gelande;
                }
            }
        }
    }
    
    return nil;
}


@end
