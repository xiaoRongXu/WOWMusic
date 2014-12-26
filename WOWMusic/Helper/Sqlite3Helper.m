//
//  Sqlite3Helper.m
//  FCL
//
//  Created by byl-Mac on 14-3-18.
//  Copyright (c) 2014年 wangbo-baiyele. All rights reserved.
//

#import "Sqlite3Helper.h"

@implementation Sqlite3Helper

//创建表
+(void)createTable:(NSString *)sql
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败");
        return;
    }
    
    //创建执行SQL语句
    char *errmsg = nil;
    if ( sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &errmsg) != SQLITE_OK) {
        NSLog(@"创建表失败");
        sqlite3_close(sqlite);
    }
    sqlite3_close(sqlite);
}

/*
 * 接口：插入数据、删除数据、修改数据
 * 参数：sql语句，argArray参数数组
 * 返回：执行是否成功
 */
+(BOOL)dealSQL:(NSString *)sql arguArray:(NSArray *) arguArray
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败");
        return NO;
    }
    
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);

    //编译SQL语句
    if( sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败: %@",sql);
        sqlite3_close(sqlite);
        return  NO;
    }
    
    for (int i=0;i< [arguArray count];i++)
    {
        id value = [arguArray objectAtIndex:i];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [NSString stringWithFormat:@"%@",value];
        }
        sqlite3_bind_text(stmt, i+1, [value UTF8String], -1, NULL);
    }
    
    if(sqlite3_step(stmt) == SQLITE_ERROR)
    {
        NSLog(@"语句执行失败");
        sqlite3_close(sqlite);
        return  NO;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    return YES;
}

+ (BOOL)mutableDealSQL:(NSArray *)sqlArray arguArray:(NSArray *)allData
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败");
        return NO;
    }
    
    char *errorMsg;
    if(sqlite3_exec(sqlite, "BEGIN", NULL, NULL, &errorMsg) == SQLITE_ERROR){
        NSLog(@"开启事务失败: %s",errorMsg);
        sqlite3_free(errorMsg);
        sqlite3_close(sqlite);
        return NO;
    }
    
    for (NSInteger i=0;i<sqlArray.count;i++) {
        NSString *sql = sqlArray[i];
        id arguArray = allData[i];
        
        //编译SQL语句
        if( sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
        {
            NSLog(@"编译失败: %@",sql);
            continue;
        }
        
        if (![arguArray isKindOfClass:[NSNull class]]) {
            for (int i=0;i< [arguArray count];i++)
            {
                id value = [arguArray objectAtIndex:i];
                if ([value isKindOfClass:[NSNumber class]]) {
                    value = [NSString stringWithFormat:@"%@",value];
                }
                sqlite3_bind_text(stmt, i+1, [value UTF8String], -1, NULL);
            }
        }
        
        if(sqlite3_step(stmt) == SQLITE_ERROR)
        {
            sqlite3_finalize(stmt);
        }
    }
    if(sqlite3_exec(sqlite, "COMMIT", NULL, NULL, &errorMsg) == SQLITE_ERROR){
        NSLog(@"事务提交失败： %s",errorMsg);
        sqlite3_free(errorMsg);
        sqlite3_close(sqlite);
        return NO;
    }
    sqlite3_close(sqlite);
    return YES;
}

+ (BOOL)setData:(NSMutableString *)sql
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败");
        return NO;
    }
    
    //编译SQL语句
    if( sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败   %s",[sql UTF8String]);
        sqlite3_close(sqlite);
        return  NO;
    }
    
    if(sqlite3_step(stmt) == SQLITE_ERROR)
    {
        NSLog(@"语句执行失败");
        sqlite3_close(sqlite);
        return  NO;
    }
    
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    return YES;
}

/*      接口：查询数据
 *      参数：sql语句
 *      返回：符合条件的数据，返回二维数组
 */

+(NSMutableArray *)selectSQL:(NSString *)sql count:(int) number
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败:%@",path);
        return data;
    }
    
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    //编译SQL语句
    
    if( sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败:%@",sql);
        sqlite3_close(sqlite);
        return  data;
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW )
    {
        if (number == 0) {
            number = sqlite3_column_count(stmt);
            NSLog(@"字段数量： %d",number);
        }
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:number];
        for(int i=0; i<number; i++)
        {
            char *temp = (char *)sqlite3_column_text(stmt, i);
            
            if(temp == NULL)
                temp = (char *)"";
            NSString *str = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
            [tempArray addObject:str];
        }
        
        [data addObject:tempArray];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    return data;
}

+(NSMutableArray *)selectSQLReturnTypeInt:(NSString *)sql
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败:%@",path);
        return data;
    }
    
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    //编译SQL语句
    
    if( sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败:%@",sql);
        sqlite3_close(sqlite);
        return  data;
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW )
    {
        int number = sqlite3_column_int(stmt, 0);
        [data addObject:@(number)];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    return data;
}

+(NSMutableArray *)selectSQLReturnDic:(NSString *)sql count:(int) number
{
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];
    sqlite3 *sqlite = nil;
    sqlite3_stmt *stmt = nil;
    NSMutableArray *data = [NSMutableArray array];
    
    //打开数据库
    if( sqlite3_open([path UTF8String], &sqlite) != SQLITE_OK )
    {
        NSLog(@"打开数据库失败:%@",path);
        return data;
    }
  
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    
    //编译SQL语句
    
    if( sqlite3_prepare_v2(sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败：%@",sql);
        sqlite3_close(sqlite);
        return  data;
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW )
    {
        if (number == 0) {
            number = sqlite3_column_count(stmt);
            NSLog(@"字段数量： %d",number);
        }
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for(int i=0; i<number; i++)
        {
            char *temp = (char *)sqlite3_column_text(stmt, i);
            char *name = (char *)sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            if(!temp)
                temp = (char *)"";
            NSString *str = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
            [tempDic setObject:str forKey:key];
        }
        
        [data addObject:tempDic];
    }
    sqlite3_finalize(stmt);
    sqlite3_close(sqlite);
    
    return data;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",kSqliteFileName];

        sqlite3 *sqlite = nil;
        
        if( sqlite3_open([self.path UTF8String], &sqlite) != SQLITE_OK )
        {
            NSLog(@"打开数据库失败");
            sqlite = nil;
            self.available = NO;
        }else{
            sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
            self.sqlite = sqlite;
            self.available = YES;
        }
    }
    return self;
}

- (BOOL)dealSQL:(NSString *)sql arguArray:(NSArray *) arguArray
{
    if (!self.available) {
        NSLog(@"初始化sqlite失败");
        return NO;
    }
    
    sqlite3_stmt *stmt = nil;
    
    //编译SQL语句
    if( sqlite3_prepare_v2(self.sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败: %@",sql);
        return  NO;
    }
    
    for (int i=0;i< [arguArray count];i++)
    {
        id value = [arguArray objectAtIndex:i];
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [NSString stringWithFormat:@"%@",value];
        }
        sqlite3_bind_text(stmt, i+1, [value UTF8String], -1, NULL);
    }
    
    if(sqlite3_step(stmt) == SQLITE_ERROR)
    {
        sqlite3_finalize(stmt);
        NSLog(@"语句执行失败:%@",sql);
        return  NO;
    }
    return YES;
}

- (NSMutableArray *)selectSQL:(NSString *)sql count:(int) number
{
    if (!self.available) {
        NSLog(@"初始化sqlite失败");
        return nil;
    }
    
    sqlite3_stmt *stmt = nil;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if( sqlite3_prepare_v2(self.sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败:%@",sql);
        return  data;
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW )
    {
        if (number == 0) {
            number = sqlite3_column_count(stmt);
        }
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:number];
        for(int i=0; i<number; i++)
        {
            char *temp = (char *)sqlite3_column_text(stmt, i);
            if(temp == NULL)
                temp = (char *)"";
            NSString *str = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
            [tempArray addObject:str];
        }
        [data addObject:tempArray];
    }
    return data;
}

- (NSMutableArray *)selectSQLReturnDic:(NSString *)sql count:(int) number
{
    if (!self.available) {
        NSLog(@"初始化sqlite失败");
        return nil;
    }
    
    sqlite3_stmt *stmt = nil;
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    if( sqlite3_prepare_v2(self.sqlite, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK )
    {
        NSLog(@"编译失败:%@",sql);
        return  data;
    }
    
    while(sqlite3_step(stmt) == SQLITE_ROW )
    {
        if (number == 0) {
            number = sqlite3_column_count(stmt);
            NSLog(@"字段数量： %d",number);
        }
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for(int i=0; i<number; i++)
        {
            char *temp = (char *)sqlite3_column_text(stmt, i);
            char *name = (char *)sqlite3_column_name(stmt, i);
            NSString *key = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            if(!temp)
                temp = (char *)"";
            NSString *str = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
            [tempDic setObject:str forKey:key];
        }
        
        [data addObject:tempDic];
    }
    
    return data;
}

- (BOOL)close
{
    if (self.sqlite) {
        sqlite3_close(self.sqlite);
        return YES;
    }else
        return NO;
}

@end
