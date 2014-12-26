//
//  AppDelegate.m
//  WOWMusic
//
//  Created by wwwbbat on 14-12-17.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if (err) {
        NSLog(@"err1: %@",err);
    }
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    if (err) {
        NSLog(@"err2: %@",err);
    }
    
    [self copyMusicList];
    return YES;
}

- (void)copyMusicList
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [Device_DocumentPath stringByAppendingPathComponent:@"wowdata.sqlite3"];
    if (![fm fileExistsAtPath:filePath]) {
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"wowdata" ofType:@"sqlite3"];
        [[NSFileManager defaultManager] copyItemAtPath:dataPath toPath:filePath error:nil];
    }
    for (NSString *keyword in WOWKeywords) {
        NSString *musicFilePath = [Device_DocumentPath stringByAppendingPathComponent:keyword];
        if (![fm fileExistsAtPath:musicFilePath]) {
            [fm createDirectoryAtPath:musicFilePath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    
    NSError *error;
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"Rise to the Dark" ofType:@"mp3"];
    NSString *toPath = [Device_DocumentPath stringByAppendingPathComponent:@"doc/Rise to the Dark.mp3"];
    [fm copyItemAtPath:musicPath toPath:toPath error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
}
@end
