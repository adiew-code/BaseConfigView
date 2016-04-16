//
//  MJButtonView.m
//  MJNSFA
//
//  Created by zhiqing on 16/3/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJButtonView.h"

@interface MJButtonView()
{
    UIButton * button;
}

@end


@implementation MJButtonView

-(BOOL)setupSubViews{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    button = [[UIButton alloc]init];
    [button setTitle:@"清除基准点" forState:UIControlStateNormal];
    BOOL enable =  ([self.configParam[kWidgetParam_Enable] boolValue]);
    if (enable) {
        [button setBackgroundColor:[UIColor colorWithRed:95/255.0 green:153/255.0 blue:243/255.0 alpha:1]];
    }else {
        [button setBackgroundColor:[UIColor grayColor]];
    
    }
    button.enabled = enable;
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [button autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [button autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [button autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [button autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:1/2.0];
    [button autoAlignAxisToSuperviewAxis:ALAxisVertical];
    return YES;
}

-(void)btnClick
{
    [self valueDidChanged];
}
-(void)setConfigParam:(NSDictionary *)configParam{
    [super setConfigParam:configParam];
    BOOL enable =  ([self.configParam[kWidgetParam_Enable] boolValue]);
    button.enabled = enable;
    if (enable) {
        [button setBackgroundColor:[UIColor colorWithRed:95/255.0 green:153/255.0 blue:243/255.0 alpha:1]];
    }else {
        [button setBackgroundColor:[UIColor grayColor]];
        
    }
}
@end
