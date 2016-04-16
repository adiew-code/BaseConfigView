//
//  UIResponder+Router.m
//  MJNSFA
//
//  Created by weida on 16/4/6.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)

-(void)routerEventWithType:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [self.nextResponder routerEventWithType:eventName userInfo:userInfo];
}

@end
