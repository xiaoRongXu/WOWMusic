//
//  WMPlayHelper.m
//  WOWMusic
//
//  Created by wwwbbat on 14-12-23.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import "WMPlayHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface WMPlayHelper ()<AVAudioPlayerDelegate>
{
    NSTimeInterval _duration;//当前播放音乐的总时间
}
@property (nonatomic) WMPlayerStatus status;
@property (strong, nonatomic) AVAudioPlayer *currentPlayer;//当前的播放器
@property (strong, nonatomic) NSMutableArray *musicQueue;  //播放列表
@property (strong, nonatomic) NSString *curMusicPath;      //当前曲目路径
@property (nonatomic) CGFloat curProgress;                 //当前播放进度

@property (strong, nonatomic) NSTimer *progressTimer;//控制进度的定时器

@end

@implementation WMPlayHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.musicQueue = [NSMutableArray array];
        self.status = WMPlayerStatusStopped;
    }
    return self;
}

//当前播放的音乐信息
+ (WMPlayHelper *)defaultPlayer
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - 播放单曲
//获取一个音乐基本数据
+ (id)wm_MusicInfoAtPath:(NSString *)filePath
{
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *fullPath = [Device_DocumentPath stringByAppendingPathComponent:filePath];
    NSDictionary *attr = [fm attributesOfItemAtPath:fullPath error:&error];
    if (error) {
        return error;
    }else{
        return attr;
    }
}
//播放一个音乐
+ (void)wm_PlayAtPath:(NSString *)filePath
{
    NSString *fullPath = [Device_DocumentPath stringByAppendingPathComponent:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        //本地播放
        [[WMPlayHelper defaultPlayer] _playOnLocal:fullPath];
    }else{
        //流播放
    }
}

#pragma mark - 播放列表
//当前播放列表
+ (NSArray *)currentPlayList
{
    return nil;
}
//创建一个播放列表，并且播放
+ (void)wm_PlayWithPathList:(NSArray *)pathList
{}
//向当前播放列表增加一个播放项目
+ (void)wm_AddToPlayListWithPath:(NSString *)filePath
{}
//获取当前列表进度
+ (CGFloat)wm_ListProgress
{
    return 0;
}

#pragma mark - 播放控制
+ (void)gotoNewProgrss:(CGFloat)progress
{}

+ (void)pause
{
    WMPlayHelper *helper = [WMPlayHelper defaultPlayer];
    [helper.currentPlayer pause];
    [helper.progressTimer invalidate];
    helper.status = WMPlayerStatusPaused;
}

+ (void)play
{
    WMPlayHelper *helper = [WMPlayHelper defaultPlayer];
    if (helper.currentPlayer) {
        [helper.currentPlayer play];
        [helper _startProgressNotification];
        helper.status = WMPlayerStatusPlaying;
    }
}

+ (void)stop
{
    WMPlayHelper *helper = [WMPlayHelper defaultPlayer];
    [helper.currentPlayer stop];
    [helper.progressTimer invalidate];
    helper.status = WMPlayerStatusStopped;
}

+ (void)exit
{}
+ (void)clean
{}

#pragma mark - 播放实现
- (void)_playOnLocal:(NSString *)fullPath
{
    if (_currentPlayer.isPlaying) {
        [_currentPlayer stop];
    }
    if (self.status == WMPlayerStatusPaused) {
        [WMPlayHelper play];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *fullURL = [NSURL fileURLWithPath:fullPath];
        NSError *error;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
            _currentPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fullURL fileTypeHint:@"mp3" error:&error];
            _currentPlayer.delegate = self;
            _currentPlayer.volume = 10.0f;
            _currentPlayer.numberOfLoops = 1;
            
            [error wm_postErrorNotification:nil];
            
//            [_currentPlayer prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
            [_currentPlayer play];//播放
            self.status = WMPlayerStatusPlaying;
            
            _duration = _currentPlayer.duration;
            [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayHelperStartPlayingNotifation object:@(_duration)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _startProgressNotification];
            });
        }
    });
}

#pragma mark - 进度相关

//
- (void)_startProgressNotification
{
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_notifiProgressValue:) userInfo:nil repeats:YES];
}

- (void)_notifiProgressValue:(NSTimer *)timer
{
    if (_duration==0) {
        _duration = _currentPlayer.duration;
    }else{
        NSTimeInterval cTime = _currentPlayer.currentTime;
        [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayHelperProgressNotification object:@[@(cTime),@(_duration)]];
    }
}

#pragma mark - AVAudioPlayer delegate
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    self.status = WMPlayerStatusPaused;
    NSLog(@"中断");
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    self.status = WMPlayerStatusStopped;
    NSLog(@"解码错误: %@",error);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.status = WMPlayerStatusStopped;
    NSLog(@"结束播放: 成功：%@",flag?@"yes":@"no");
}



@end
