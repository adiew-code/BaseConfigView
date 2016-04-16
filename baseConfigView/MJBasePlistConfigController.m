//
//  MJBasePlistConfigController.m
//  MJNSFA
//
//  Created by weida on 16/2/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJBasePlistConfigController.h"
#import "PureLayout.h"


#define kVSpace     (8) //垂直间距
#define kHSpace     (20)

@interface MJBasePlistConfigController ()
{
    MJBasePlistConfigView *_baseConfigView;
}
@end

@implementation MJBasePlistConfigController

-(void)initData
{
    // Do nothing . subClass need override this method to init it's Data
}

-(void)loadView
{
    [self initData];
    [super loadView];
    _baseConfigView = [[MJBasePlistConfigView alloc]initWithDelegate:self];
    [self.view addSubview:_baseConfigView];
    [_baseConfigView autoPinEdgesToSuperviewEdgesWithInsets:[self baseConfigViewEdgeInsets]];
}

-(void)rowViewUpdateAtIndex:(NSInteger)index FirstWidgetView:(MJBaseWidgetView *)firstView SecondWidgetView:(MJBaseWidgetView *)secondView
{
    
}

-(UIEdgeInsets)baseConfigViewEdgeInsets
{
    return UIEdgeInsetsMake(0,0,0,0);
}

-(UIEdgeInsets)rowViewEdgeInsetsAtIndex:(NSInteger)row
{
    return UIEdgeInsetsMake(kVSpace,kHSpace, kVSpace,kHSpace);
}

-(NSDictionary *)rowViewWillinitRow:(NSInteger)row Index:(NSInteger)index configParam:(NSDictionary *)configParam
{
    return configParam;//Default
}

-(MJBasePlistConfigView *)baseConfigView
{
    return _baseConfigView;
}


@end
