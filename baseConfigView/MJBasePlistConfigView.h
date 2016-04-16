//
//  MJBasePlistConfigView.h
//  MJNSFA
//
//  Created by weida on 16/3/7.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MJBaseWidgetViewDelegate;

#define kRowViewTagBase    (1000)

@class MJBaseWidgetView;

@protocol MJBasePlistConfigViewDelegate <NSObject>

@required


/**
 *  @brief 更新第index行的视图,子类重新此函数更新每一行的数据
 *
 *  @param index      第index行视图
 *  @param firstView  该行上的第一个控件
 *  @param secondView 该行上的第二个控件
 */
-(void)rowViewUpdateAtIndex:(NSInteger)index FirstWidgetView:(MJBaseWidgetView*)firstView SecondWidgetView:(MJBaseWidgetView*)secondView;

@optional

/**
 *  @brief 初始化第row行第index个控件时，配置参数为configParam，用户可以重新此方法，在初始化之前修改配置参数，并返回，默认直接返回configParam(也就是不做修改)
 *
 *  @param row         第几行？
 *  @param index       该行的第几个？
 *  @param configParam 该控件对应的配置参数
 *
 *  @return 返回修改后的配置参数（默认直接返回configParam）
 */
-(NSDictionary*)rowViewWillinitRow:(NSInteger)row Index:(NSInteger)index configParam:(NSDictionary*)configParam;

/**
 *  @brief 第row行的上下左右间距(子类可以重写此函数实现不同布局)
 *
 *  @param row 当前是第几行？从0开始
 *
 *  @return 返回间距
 */
-(UIEdgeInsets)rowViewEdgeInsetsAtIndex:(NSInteger)row;


@end




@interface MJBasePlistConfigView : UIScrollView<MJBasePlistConfigViewDelegate>

@property(nonatomic,weak)id <MJBasePlistConfigViewDelegate>delegateConfig;

-(instancetype)initWithDelegate:(__weak id <MJBasePlistConfigViewDelegate>)delegate;


/**
 *  @brief 刷新整个界面，更新所有行
 */
- (void)reloadData;

-(void)deleteRowAt:(NSInteger)row;
-(void)insertRowsAt:(NSInteger)row configs:(NSArray*)configs;


-(id)getValueByRow:(NSInteger)row Index:(NSInteger)index;

-(MJBaseWidgetView*)getWidgetByRow:(NSInteger)row Index:(NSInteger)index;

/**
 *  @brief 检验所有控件输入是否合法？
 *
 *  @return 全部合法返回YES，否则返回NO
 */
-(BOOL)checkInputOfAllWidget;

@end
