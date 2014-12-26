//
//  NSError+ErrorNotification.h
//  WOWMusic
//
//  Created by wwwbbat on 14-12-25.
//  Copyright (c) 2014年 wwwbbat. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const WMPlayHelperErrorNotification;

@interface NSError (ErrorNotification)

- (void)wm_postErrorNotification:(id)object;

@end
