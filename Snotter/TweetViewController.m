//
//  TweetViewController.m
//  Snotter
//
//  Created by 松瀬 弘樹 on 12/10/28.
//  Copyright (c) 2012年 松瀬 弘樹. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetStatus.h"
#import "WebBrowserViewController.h"

@interface TweetViewController ()

@property (nonatomic) TweetStatus *status;

@end

@implementation TweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStatus:(TweetStatus *)status
{
    self = [super initWithNibName:@"TweetViewController" bundle:nil];
    if (self) {
        
        self.status = status;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ユーザ情報表示
    [self.imgProfile loadImageWithURL:self.status.profile_image_url_https];
    self.imgProfile.layer.cornerRadius = 5;
    self.imgProfile.clipsToBounds = true;
    self.lblUserName.text = self.status.name;
    self.lblScreenName.text = [NSString stringWithFormat:@"@%@", self.status.screen_name];
    self.tweetTableView.tableHeaderView = self.userView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserView:nil];
    [self setTweetTableView:nil];
    [self setImgProfile:nil];
    [self setLblUserName:nil];
    [self setLblScreenName:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
            if (cell == nil)
                cell = [self createTweetCellWithReuseIdentifier:@"tweetCell"];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell"];
            if (cell==nil)
                cell = [self createFooterCellWithReuseIdentifier:@"infoCell"];
            break;
    }

    return cell;
}

- (UITableViewCell *)createTweetCellWithReuseIdentifier:(NSString *)identifier
{
    //セル生成
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
	//セル選択時の色表示を解除
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	//セル矩形を保持
	CGRect cellFrame = [cell frame];
    
    // セルの大きさからセル表示テキスト部分の矩形取得（高さ以外）
    CGRect contentOrigin = CGRectInset(cell.contentView.bounds, 20, 5);
    
    // セルの表示テキストのサイズを取得
    CGSize cellContntSize = [self.status.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0]
                                         constrainedToSize:CGSizeMake(contentOrigin.size.width, 500)
                                             lineBreakMode:UILineBreakModeCharacterWrap];
    
    //セル高さを更新
	cellFrame.size.height = cellContntSize.height + 10;
	[cell setFrame:cellFrame];
    
    //HTMLデータに変換
	NSMutableArray *filteredLines = [self makeHTMLString:self.status.text];

    //本文HTMLを生成
    NSString *htmlTemplate = @"<html></script></head><body style=\"width:%f; background-color: transparent; font-family:Helvetica; font-size:14.0px; overflow:visible; padding:0; margin:0\">%@</body></html>";
    
    NSString *html = [NSString stringWithFormat:
                      htmlTemplate,
                      cellContntSize.width,
                      [filteredLines componentsJoinedByString:@"<br>"]];
    
    // WebView生成
    UIWebView *tweet = [[UIWebView alloc] initWithFrame:CGRectMake(contentOrigin.origin.x,
                                                                   contentOrigin.origin.y,
                                                                   cellContntSize.width,
                                                                   cellContntSize.height)];
	[tweet setDelegate:self];
	[tweet loadHTMLString:html baseURL:nil];
	tweet.scalesPageToFit = NO;
	tweet.backgroundColor = [UIColor clearColor];
    tweet.opaque = NO;
    
	[cell addSubview:tweet];

    return cell;
}

- (UITableViewCell *)createFooterCellWithReuseIdentifier:(NSString *)identifier
{
    //セル生成
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    CGRect cellFrame = cell.frame;
	cellFrame.size.height = 25;
	[cell setFrame:cellFrame];

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.text = [self dateToString:self.status.date];
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0];
    return cell;
}

- (NSString *)dateToString:(NSDate *)date
{
    NSCalendarUnit unit =   NSYearCalendarUnit |
                            NSMonthCalendarUnit |
                            NSDayCalendarUnit |
                            NSHourCalendarUnit |
                            NSMinuteCalendarUnit;
    
    NSDateComponents* tweetDateComponents = [[NSCalendar currentCalendar] components:unit fromDate:date];
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    // 時間をのぞいた日付で比較する
	NSString *tmpDate = nil;
    tmpDate = [dateFormatter stringFromDate:date];
	NSDate *tweetDate = [dateFormatter dateFromString:tmpDate];
    tmpDate = [dateFormatter stringFromDate:[NSDate date]];
	NSDate *nowDate = [dateFormatter dateFromString:tmpDate];
    
    NSDateComponents *compare = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                fromDate:tweetDate
                                                                  toDate:nowDate
                                                                 options:0];
    if (compare.day == 0) {
        
        return [NSString stringWithFormat:@"%d:%02d",
                tweetDateComponents.hour,
                tweetDateComponents.minute];
    }
    else if (compare.day == 1) {
        
        return [NSString stringWithFormat:@"昨日 %d:%02d",
                tweetDateComponents.hour,
                tweetDateComponents.minute];
    }
    else {
        
        return [NSString stringWithFormat:@"%d/%d %d:%02d",
                tweetDateComponents.month,
                tweetDateComponents.day,
                tweetDateComponents.hour,
                tweetDateComponents.minute];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([[[request URL] absoluteString] isEqualToString:@"about:blank"])
		return YES;
    
    WebBrowserViewController *ctl = [[WebBrowserViewController alloc] initWithURL:[request.URL absoluteString]];
    ctl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:ctl animated:YES];
    
    return NO;
}

#pragma mark -

- (NSMutableArray *)makeHTMLString:(NSString *)text
{
	//行作業用変数
	NSString *line;
	
	//リンク文字列変換
	NSString *convText = [self convertLinkString:text];
	
	//行配列取得（オリジナル）
	NSArray *lines = [convText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		
	//行数保持
	int newLineCounter = [lines count];
	
	//行配列（変換用）
	NSMutableArray *filteredLines = [[NSMutableArray alloc] initWithCapacity:newLineCounter];
	
	//列挙子取得
	NSEnumerator *en = [lines objectEnumerator];
	
	//行数分繰り返す
	while((line = [en nextObject]))
	{
		//単語作業用変数
		NSString *word;
		
		//単語配列取得（オリジナル）
		NSArray *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		//単語配列（変換用）
		NSMutableArray *filteredWords = [[NSMutableArray alloc] initWithCapacity:[words count]];
		
		//単語数分繰り返す
        NSEnumerator *en = [words objectEnumerator];
		while((word = [en nextObject]))
		{
			//URLチェック
			if([word hasPrefix:@"http://"] || [word hasPrefix:@"https://"] || [word hasPrefix:@"www"])
			{
				//「www」で始まる場合は「http://」を付加
				if([word hasPrefix:@"www"])
					word = [@"http://" stringByAppendingString:word];
								
				//リンクHTMLタグに変換する
                word = [NSString  stringWithFormat:@"<a href=%@>%@</a>", word, word];
			}
			else if([word hasPrefix:@"@"] && [word length] > 1)
			{
				//@で始まっている場合はリプライとして扱う
				word = [NSString  stringWithFormat:@" <font color=\"Blue\">%@</font> ", word];
			}
			else if([word hasPrefix:@"#"] && [word length] > 1)
			{
				//#で始まっている場合はハッシュタグとして扱う
				word = [NSString  stringWithFormat:@" <font color=\"Blue\">%@</font> ", word];
			}
			
			//変換後の単語配列に追加
			[filteredWords addObject:word];
		}
		
		//変換後の行配列に追加
		[filteredLines addObject:[filteredWords componentsJoinedByString:@""]];
	}
	
	return filteredLines;
}

- (NSString*)convertLinkString:(NSString*)text
{
	NSString *converted = text;
	converted =[converted stringByReplacingOccurrencesOfString:@"http:" withString:@" http:"];
	converted =[converted stringByReplacingOccurrencesOfString:@"https:" withString:@" https:"];
	converted =[converted stringByReplacingOccurrencesOfString:@"@" withString:@" @"];
	converted =[converted stringByReplacingOccurrencesOfString:@"#" withString:@" #"];
	
	return converted;
}

@end
