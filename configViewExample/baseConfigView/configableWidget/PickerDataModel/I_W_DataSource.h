//
//  I_W_DataSource.h
//  MJNSFA
//
//  Created by winchannel on 16/2/27.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//
#import "I_W_BuildInfo.h"
#import <Foundation/Foundation.h>

@protocol I_W_DataSource <NSObject>

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo>* )buildInfo;

@end
