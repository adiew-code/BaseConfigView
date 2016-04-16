//
//  NSArray+safety.h
//  MJNSFA
//
//  Created by weida on 16/3/1.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (safety)
/**
 *  @brief 避免越界奔溃
 *
 *  @param index 第几个个？
 *
 *  @return 不越界返回第index个，越界返回nil
 */
-(id)objectAtIndexEx:(NSUInteger)index;

@end
