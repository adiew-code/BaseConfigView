//
//  MJBaseWidget.m
//  MJNSFA
//
//  Created by weida on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJBaseWidgetView.h"
#import "UIView+TTCategory.h"


/**
 *    所有控件通用配置参数
 */
NSString* kWidgetParam_PlaceHolder      =      (@"placeholder"); //设置TextView的placeHolder文本
NSString* kWidgetParam_Lable            =       (@"lable"); //设置控件最前面的Lable显示的文本
NSString* kWidgetParam_LableWidth       =      (@"width_lable");//设置控件最前面的Lable显示的宽度
NSString* kWidgetParam_Enable           =      (@"enable");    //是否允许用户交互,默认YES
NSString* kWidgetParam_DataSource       =       (@"data_source");//数据源
NSString* kWidgetParam_Required         =       (@"required");//是否是必填项,默认0,如果为1,最前面会有一个红色的*表示必填
NSString* kWidgetParam_Horizontaloffset =       (@"horizontal_offset");//可选项,Lable和textView水平间距
NSString* kWidgetParam_Height           =       (@"height");//可选项，固定控件高度
NSString* kWidgetParam_MinHeight        =       (@"minheight");//设置控件最小高度
NSString* kWidgetParam_Delegate         =       (@"delegate");//设置控件的delegate

/**
 *  @brief   MJInputTextView个性化配置参数
 */
NSString* kWidgetParam_Text            =       (@"text"); //设置TextView要显示的文本
NSString* kWidgetParam_InputMaxCount   =      (@"maxCount");//设置TextView可以输入的最大个数
NSString* kWidgetParam_KeyboardType    =      (@"keyBoardType");//设置输入键盘类型
NSString* kWidgetParam_InputNumberOnly =      (@"numberOnly");//设置输入是否只允许输入数字

/**
 *  @brief   MJPickerDataView个性化配置参数
 */
NSString* kWidgetParam_datasourceIndex =      (@"datasourceIndex"); // 从数据库获取数据源

/**
 *  @brief   MJMultipleChoiceView、MJRadioButtonView个性化配置参数
 */
NSString* kWidgetParam_CountOfOneRow    =       (@"countOneRow");//一行显示多少个选项？可选
NSString* kWidgetParam_currentSelected  =       (@"currentSelected");//当前选中的是哪个?
NSString* kWidgetParam_VerticalRowInset =       (@"verticalRowInset");//多行的垂直间距，默认为0


/**
 *  @brief 设置DatePicker个性化参数
 */
NSString* kWidgetParam_DatePickerMode   =       (@"datePickerMode");//时间模式
NSString* kWidgetParam_DatePickerMinDate=       (@"minDate");//最小时间
NSString* kWidgetParam_DatePickerMaxDate=       (@"maxDate");//最大时间

/**
 *  @brief   MJGrid视图个性化配置参数
 */
NSString* kWidgetParam_ShouldShowSumRow =      (@"ShowSumRow");//是否显示总计？可选
NSString* kWidgetParam_ShouldShowProductLine =      (@"ShowProductLine");//是否显示总计？可选

@interface MJBaseWidgetView ()
{
    BOOL _hasSetupSubVies;//setupSupViews函数只能执行一次，防止多次调用导致奔溃
    
    /**
     *  @brief 控件所在控制器
     */
    __weak UIViewController *_viewController;
}
@end

@implementation MJBaseWidgetView


-(instancetype)initWithConfigParam:(NSDictionary *)configParam
{
    [self setConfigParam:configParam];
    self = [self init];
    if (self)
    {
    }
    return self;
}

-(instancetype)init
{
    self =  [super init];
    if (self)
    {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


-(BOOL)setupSubViews
{
    if (!_hasSetupSubVies)
    {
        if (!self.configParam)//Set some Default Value
            [self setConfigParam:@{}];
            
        _hasSetupSubVies =  YES;
        return NO;//第一次返回NO,此后都返回YES
    }
    return _hasSetupSubVies;
}

/**
 *  @brief 每次设置,不会覆盖之前的设置
 *
 *  @param configParam 配置信息
 */
-(void)setConfigParam:(NSDictionary *)configParam
{
    if (configParam[kWidgetParam_Delegate])
    {//如果配置了控件的Delegate
        self.delegate = configParam[kWidgetParam_Delegate];
    }
    
    if (_configParam)
    {
        NSMutableDictionary *mutable = _configParam.mutableCopy;
        [mutable addEntriesFromDictionary:configParam];
        [mutable removeObjectForKey:kWidgetParam_Delegate];//避免强引用
        _configParam = mutable;
    }else
    {
        NSMutableDictionary *mutable = configParam.mutableCopy;
        [mutable removeObjectForKey:kWidgetParam_Delegate];//避免强引用
        if (!configParam[kWidgetParam_Enable])
        {//用户没有设置,默认为YES
            mutable[kWidgetParam_Enable] = @(YES);
        }
        _configParam = mutable;
        
    }
}

-(void)valueWillChanged
{
    if ([self.delegate respondsToSelector:@selector(valueWillChangedWidget:row:Index:)])
    {
        [self.delegate valueWillChangedWidget:self row:(self.tag>>8)-1 Index:self.tag & 0x00FF];
    }else if ([self.currentController respondsToSelector:@selector(valueWillChangedWidget:row:Index:)])
    {
        [self.currentController valueWillChangedWidget:self row:(self.tag>>8)-1 Index:self.tag & 0x00FF];
    }
}

-(void)valueDidChanged
{
    if ([self.delegate respondsToSelector:@selector(valueDidChangedWidget:row:Index:)])
    {
        [self.delegate valueDidChangedWidget:self row:(self.tag>>8)-1 Index:self.tag & 0x00FF];
    }else   if ([self.currentController respondsToSelector:@selector(valueDidChangedWidget:row:Index:)])
    {
        [self.currentController valueDidChangedWidget:self row:(self.tag>>8)-1 Index:self.tag & 0x00FF];
    }
}

-(UIViewController *)currentController
{
    if (_viewController)
        return _viewController;
    
    return _viewController = self.viewController;
}

-(id)value
{
    return nil;
}



-(CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, kDefaultHeight+[self.configParam[kWidgetParam_MinHeight]integerValue]);
}

/**
 *  @brief 只有带输入框的才可能YES，其他的都NO
 *
 *  @return 默认NO,MJinputTextView才有可能为YES
 */
-(BOOL)canBecomeFirstResponder
{
    return NO;
}

@end
