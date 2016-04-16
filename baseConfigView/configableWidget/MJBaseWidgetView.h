//
//  MJBaseWidget.h
//  MJNSFA
//
//  Created by weida on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"

@protocol I_W_BuildInfo;
@protocol I_W_DataSource;

#define kDefaultHeight     (40)//控件默认高度
#define kBtnNomalBkColor    ([UIColor colorWithRed:0.114 green:0.502 blue:0.765 alpha:1])
#define kBtnDisableBkColor  ( [UIColor grayColor])


///////////////////////////////////////////////////所有控件通用设置参数//////////////////////////////////////////////////

/**
 *  @brief 设置控件最小高度
 */
extern NSString* kWidgetParam_MinHeight;

/**
 *  @brief 设置控件没有数据时显示的占位信息
 */
extern NSString* kWidgetParam_PlaceHolder;

/**
 *  @brief 设置控件内部Lable和其右边视图的水平间距
 */
extern NSString* kWidgetParam_Horizontaloffset;

/**
 *  @brief 设置控件最前面的Lable显示的文本
 */
extern NSString* kWidgetParam_Lable;

/**
 *  @brief 设置控件最前面的Lable显示的宽度
 */
extern NSString* kWidgetParam_LableWidth;

/**
 *  @brief 是否允许用户交互,默认YES
 */
extern NSString* kWidgetParam_Enable ;

/**
 *  @brief 设置控件的数据源
 */
extern NSString* kWidgetParam_DataSource ;

/**
 *  @brief 是否是必填项,默认0,如果为1,最前面会有一个红色的*表示必填
 */
extern NSString* kWidgetParam_Required ;

/**
 *  @brief 默认控件高度是跟随数据源动态变化的，可通过此参数固定高度
 */
extern NSString* kWidgetParam_Height;

/**
 *  @brief 设置控件的delegate
 */
extern NSString* kWidgetParam_Delegate;


///////////////////////////////////////////////////MJInputTextView控件个性化参数//////////////////////////////////////////////////
/**
 *  @brief   设置TextView要显示的文本
 */
extern NSString* kWidgetParam_Text;
/**
 *  @brief 设置TextView可以输入的最大个数
 */
extern NSString* kWidgetParam_InputMaxCount;

/**
 *  @brief 设置弹出键盘类型
 */
extern NSString* kWidgetParam_KeyboardType;

/**
 *  @brief 设置输入框是否只接受数字？
 */
extern NSString* kWidgetParam_InputNumberOnly;

/////////////////////////////////////////MJDatePickerView控件个性化参数////////////////////////////////////////////////

/**
 *  @brief 设置DatePicker时间选择模式
 */
extern NSString* kWidgetParam_DatePickerMode;

/**
 *  @brief 设置DatePicker最小时间
 */
extern NSString* kWidgetParam_DatePickerMinDate;

/**
 *  @brief 设置DatePicker最大时间
 */
extern NSString* kWidgetParam_DatePickerMaxDate;


/////////////////////////////////////////MJPickerDataView控件个性化参数////////////////////////////////////////////////
/**
 *  @brief 设置下拉初始化数据源
 */
extern NSString* kWidgetParam_datasourceIndex;



///////////////////////////////////////////////////MJRadioButtonView、MJMultipleChoiceView控件个性化参数//////////////////////////////////////////////////
/**
 *  @brief   一行显示多少个选项？可选
 */
extern NSString* kWidgetParam_CountOfOneRow;

/**
 *  @brief   当前选中的是哪个选项?
 */
extern NSString* kWidgetParam_currentSelected;

/**
 *  @brief 多行垂直间距
 */
extern NSString* kWidgetParam_VerticalRowInset;

/////////////////////////////////////////////////MJBaseGridView控件个性化参数//////////////////////////

/**
 *  @brief  是否显示总计？可选
 */
extern NSString* kWidgetParam_ShouldShowSumRow;

/**
 *  @brief 是否显示产品线？可选
 */
extern NSString* kWidgetParam_ShouldShowProductLine;

#define kWidgetValueKey_SelectedIndex    (@"index")
#define kWidgetValueKey_SelectedTitle    (@"title")
#define kFont [UIFont systemFontOfSize:13]//([UIFont fontWithName:@"Helvetica-Light" size:13.0f])

@class MJInterAction;

@class MJBaseWidgetView;

@protocol MJBaseWidgetViewDelegate <NSObject>

@optional
//执行某类操作
-(void)executeInterAction:(MJInterAction *)interaction;

/**
 *  @brief widget控件值将要改变
 *
 *  @param widget 改变值的控件
 *  @param row    该控件在第几行?
 *  @param index  该控件在该行中第几个?
 */
-(void)valueWillChangedWidget:(MJBaseWidgetView*)widget row:(NSInteger)row Index:(NSInteger)index;

/**
 *  @brief widget控件值已经改变
 *
 *  @param widget 改变值的控件
 *  @param row    该控件在第几行?
 *  @param index  该控件在该行中第几个?
 */
-(void)valueDidChangedWidget:(MJBaseWidgetView*)widget row:(NSInteger)row Index:(NSInteger)index;

/*针对表格 初始化的时候赋值*/
- (NSString *)widget:(MJBaseWidgetView *)widget dataSource:(NSObject *)dataSource currentCell:(UIView *)view columnId:(NSString *)cId rowId:(NSString *)rId;

/*针对表格 如果配置dynamicReadonly = 1 初始化的时候获取是否readonly*/
- (BOOL)isReadonlyForColumnId:(NSString *)cId rowId:(NSString *)rId;

@end


@interface MJBaseWidgetView : UIView

-(instancetype)initWithConfigParam:(NSDictionary*)configParam;

@property (nonatomic,weak) id<MJBaseWidgetViewDelegate>  delegate;

/**
 *  @brief 包含控件的各个配置信息,,默认nil
 */
@property(nonatomic,strong)NSDictionary *configParam;

/**
 *  @brief 获取控件的值
 */
@property(nonatomic,strong,readonly)id value;

/**
 *  @brief 当前控件所在控制器
 */
@property(nonatomic,weak,readonly)UIViewController <MJBaseWidgetViewDelegate>*currentController;

@property (nonatomic, strong)MJInterAction *currentInterAction;

@property (nonatomic, strong)NSMutableDictionary *interActionDict;//动作映射


#pragma mark - Private Method

/**
 *  @brief 子类重写此方法，初始化自己内部的所有子控件
 *
 *  @return 已经初始化了返回YES，没有初始化返回NO
 */
-(BOOL)setupSubViews;

- (void)buildDisplayContent;

-(void)valueWillChanged;
-(void)valueDidChanged;
@end
