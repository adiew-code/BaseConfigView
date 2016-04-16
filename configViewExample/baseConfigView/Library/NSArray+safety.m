//
//  NSArray+safety.m
//  MJNSFA
//
//  Created by weida on 16/3/1.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "NSArray+safety.h"

@implementation NSArray (safety)

-(id)objectAtIndexEx:(NSUInteger)index
{
    if (self.count <= index)
        return nil;
    
    return self[index];
}

@end
