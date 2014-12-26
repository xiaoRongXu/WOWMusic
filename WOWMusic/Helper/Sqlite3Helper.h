//
//  Sqlite3Helper.h
//  FCL
//
//  Created by byl-Mac on 14-3-18.
//  Copyright (c) 2014年 wangbo-baiyele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Sqlite3Helper : NSObject

@property (atomic) BOOL available;
@property (atomic) NSString *path;
@property (atomic) sqlite3 *sqlite;

+ (void)createTable:(NSString *)sql;

+ (BOOL)setData:(NSString *)sql;

+ (BOOL)dealSQL:(NSString *)sql arguArray:(NSArray *) arguArray;

+ (BOOL)mutableDealSQL:(NSArray *)sqlArray arguArray:(NSArray *)arguArray;

//返回二维数组 number为0时返回所有字段
+ (NSMutableArray *)selectSQL:(NSString *)sql count:(int) number;

//用于查找单个int类型数据，返回一维数组
+(NSMutableArray *)selectSQLReturnTypeInt:(NSString *)sql;

//返回数组，每一行搜索结果为字典，key为字段名。 number 为0时返回所有字段
+(NSMutableArray *)selectSQLReturnDic:(NSString *)sql count:(int) number;


- (id)init;
- (BOOL)dealSQL:(NSString *)sql arguArray:(NSArray *) arguArray;

- (BOOL)close;

- (NSMutableArray *)selectSQL:(NSString *)sql count:(int) number;

//返回数组，每一行搜索结果为字典，key为字段名。 number 为0时返回所有字段
- (NSMutableArray *)selectSQLReturnDic:(NSString *)sql count:(int) number;

@end
