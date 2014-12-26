//
//  WMPlayHelper.h
//  WOWMusic
//
//  Created by wwwbbat on 14-12-23.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMPlayNotificationHelper.h"
#import "NSError+ErrorNotification.h"

typedef NS_ENUM(NSUInteger, WMPlayerStatus)
{
    WMPlayerStatusStopped = 0,  //停止
    WMPlayerStatusPlaying = 1,  //正在播放
    WMPlayerStatusWaiting = 2,  //等待
    WMPlayerStatusPaused = 3,   //暂停
};

@interface WMPlayHelper : NSObject
@property (nonatomic, readonly) WMPlayerStatus status;
@property (nonatomic, readonly) NSString *musicName;

//当前播放的音乐信息
+ (WMPlayHelper *)defaultPlayer;

#pragma mark - 播放单曲
//获取一个音乐基本数据
+ (id)wm_MusicInfoAtPath:(NSString *)filePath;
//播放一个音乐
//返回音乐总时间
+ (void)wm_PlayAtPath:(NSString *)filePath;

#pragma mark - 播放列表
//当前播放列表
+ (NSArray *)currentPlayList;
//创建一个播放列表，并且播放
+ (void)wm_PlayWithPathList:(NSArray *)pathList;
//向当前播放列表增加一个播放项目
+ (void)wm_AddToPlayListWithPath:(NSString *)filePath;
//获取当前列表进度
+ (CGFloat)wm_ListProgress;

#pragma mark - 播放控制
+ (void)gotoNewProgrss:(CGFloat)progress;
+ (void)pause;
+ (void)play;
+ (void)stop;
+ (void)exit;
+ (void)clean;

@end
