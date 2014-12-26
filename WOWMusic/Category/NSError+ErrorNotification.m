//
//  NSError+ErrorNotification.m
//  WOWMusic
//
//  Created by wwwbbat on 14-12-25.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import "NSError+ErrorNotification.h"

NSString *const WMPlayHelperErrorNotification = @"WMPlayHelperErrorNotification";

@implementation NSError (ErrorNotification)

- (void)wm_postErrorNotification:(id)object
{
    if (self) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayHelperErrorNotification object:self userInfo:object?@{@"object":object}:nil];
    }
}
@end
