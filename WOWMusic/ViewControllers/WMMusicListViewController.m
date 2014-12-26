//
//  WMMusicListViewController.m
//  WOWMusic
//
//  Created by wwwbbat on 14-12-22.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import "WMMusicListViewController.h"
#import "Sqlite3Helper.h"
#import "WMPlayHelper.h"

#define kCellHeight 48.0f

@interface WMMusicListViewController ()
{
    NSIndexPath *_lastOne;
    NSIndexPath *_thisOne;
    
    NSString *_currentMusicName;
}
@property (nonatomic) CGFloat currentProgress;
@property (strong, nonatomic) UISlider *currentSlider;

@property (strong, nonatomic) UIBarButtonItem *playButton;
@property (strong, nonatomic) UIBarButtonItem *stopButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;

@property (strong, nonatomic) NSMutableArray *musicList;
@property (strong, nonatomic) NSMutableArray *existList;

@property (strong, nonatomic) UIToolbar *moreInfoView;

@end

@implementation WMMusicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshMusicList];
    [self initializeToolBar];
}

#pragma mark - Toolbar 相关
- (void)initializeToolBar
{
    _moreInfoView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kCellHeight, Device_Width, kCellHeight)];
    _moreInfoView.barStyle = UIBarStyleBlack;
    _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startPlaying:)];
    _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopPlaying:)];
    _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToPlayList:)];
    [_moreInfoView setItems:@[kUIBarButtonItemFix,_playButton,kUIBarButtonItemFix,_stopButton,kUIBarButtonItemFix,_addButton,kUIBarButtonItemFix]];
}

- (void)changeToolBarPlayStatusTo:(UIBarButtonSystemItem)systemItem
{
    SEL action = systemItem==UIBarButtonSystemItemPlay?@selector(startPlaying:):@selector(pausePlaying:);
    _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:action];
    [_moreInfoView setItems:@[kUIBarButtonItemFix,_playButton,kUIBarButtonItemFix,_stopButton,kUIBarButtonItemFix,_addButton,kUIBarButtonItemFix] animated:YES];
}

- (void)startPlaying:(id)sender
{
    [self changeToolBarPlayStatusTo:UIBarButtonSystemItemPause];
    
    NSArray *list = _thisOne.section==0?_existList:_musicList;
    _currentMusicName = @"Rise to the Dark.mp3";
    NSString *musicFilePath = [NSString stringWithFormat:@"%@/%@",self.listTag,_currentMusicName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willStartPlay:) name:WMPlayHelperStartPlayingNotifation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerProgress:) name:WMPlayHelperProgressNotification object:nil];
    [WMPlayHelper wm_PlayAtPath:musicFilePath];
}

- (void)addToPlayList:(id)sender
{}

- (void)addToDownloadList:(id)sender
{}

- (void)stopPlaying:(id)sender
{
    [self changeToolBarPlayStatusTo:UIBarButtonSystemItemPlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WMPlayHelperStartPlayingNotifation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WMPlayHelperProgressNotification object:nil];
    [WMPlayHelper stop];
}

- (void)pausePlaying:(id)sender
{
    [self changeToolBarPlayStatusTo:UIBarButtonSystemItemPlay];
    [WMPlayHelper pause];
}

#pragma mark - 播放显示
- (void)willStartPlay:(NSNotification *)noti
{
    NSNumber *duration = noti.object;
    NSLog(@"%@",duration);
}

- (void)playerProgress:(NSNotification *)noti
{
    NSArray *progress = noti.object;
    
    CGFloat curTime = [progress[0] floatValue];
    CGFloat duration = [progress[1] floatValue];
    _currentProgress = curTime/duration;
    [self.tableView reloadRowsAtIndexPaths:@[_thisOne] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"当前时间：%.2f，总长度：%.2f 进度：%.2f",curTime,duration,_currentProgress);
}

- (void)refreshMusicList
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM music WHERE type ='%@' order by 'index'",self.listTag];
    _musicList= [Sqlite3Helper selectSQLReturnDic:sql count:0];
    [_musicList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"index"] compare:obj2[@"index"]];
    }];
    _existList = [NSMutableArray array];
    for (NSDictionary *musicInfo in _musicList) {
        NSString *name = musicInfo[@"name"];
        NSString *filePath = [Device_DocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",self.listTag,name]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [_existList addObject:musicInfo];
        }
    }
    [_musicList removeObjectsInArray:_existList];
}

- (void)showMoreInfo:(UITapGestureRecognizer *)tap
{
    UILabel *sender = (UILabel *)tap.view;
    UIView *contentView = [sender superview];
    _currentSlider = (UISlider *)[contentView viewWithTag:3];
    UITableViewCell *cell = (UITableViewCell *)contentView.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (!_lastOne) {    //没有打开的Cell
        _thisOne = indexPath;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        _lastOne = indexPath;
    }
    else if ([indexPath compare:_lastOne] == NSOrderedSame) {    //点击上一次打开的cell
        _thisOne = nil;
        _lastOne = nil;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{   //点击另外一个cell，关闭上一个cell
        
        [_moreInfoView removeFromSuperview];
        
        NSLog(@"点击另外一个cell: row:%d, last:%d",indexPath.row,_lastOne.row);
        _thisOne = indexPath;
        [self.tableView reloadRowsAtIndexPaths:@[_lastOne,indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        _lastOne = indexPath;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==0?_existList.count:_musicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WMMusicListTableViewCellID forIndexPath:indexPath];
    UILabel *lLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *rLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UISlider *slider = (UISlider *)[cell.contentView viewWithTag:3];
    lLabel.text = [NSString stringWithFormat:@"%d",indexPath.row+1];
    rLabel.text = _musicList[indexPath.row][@"name"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMoreInfo:)];
    [rLabel addGestureRecognizer:tap];
    
    if (_thisOne && [_thisOne compare:indexPath] == NSOrderedSame) {
        [cell.contentView addSubview:_moreInfoView];
        slider.value = _currentProgress;
        slider.alpha = 1;
        cell.separatorInset = UIEdgeInsetsMake(0, Device_Width, 0, 0);
    }else{
        cell.separatorInset = UIEdgeInsetsMake(0, 48, 0, 0);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_thisOne && [_thisOne compare:indexPath] == NSOrderedSame) {
        return kCellHeight * 2;
    }else{
        return kCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _existList.count==0?0.f:48.0f;
    }else{
        return _musicList.count==0?0.f:48.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _existList.count != 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 48)];
        view.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, Device_Width, view.frame.size.height-8*2)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = [NSString stringWithFormat:@"已下载 (%d首)",_existList.count];
        [view addSubview:label];
        return view;
    }else if (section == 1 && _musicList.count != 0){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 48)];
        view.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, Device_Width, view.frame.size.height-8*2)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = [NSString stringWithFormat:@"未下载 (%d首)",_musicList.count];
        [view addSubview:label];
        return view;
    }else{
        return nil;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_moreInfoView.superview) {
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        if (![indexPaths containsObject:_thisOne]) {
            [_moreInfoView removeFromSuperview];
        }
    }
}



@end
