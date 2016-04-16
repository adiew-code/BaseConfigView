//
//  MJMJStoresDetailRowView.m
//  MJNSFA
//
//  Created by weida on 16/2/4.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJBasePlistConfigRowView.h"
#import "PureLayout.h"
//#import "MJBaseGridView.h"
#import "MJBasePlistConfigView.h"
#import "UIView+Shake.h"
#import "MJBaseWidgetView.h"


#define kHSpace          (80)//两个控件之间距离
#define kClassName       (@"widget_class")


@interface MJBasePlistConfigRowView ()
{
    /**
     *  @brief 一行的第一个控件
     */
    MJBaseWidgetView *_firstView;
    
    /**
     *  @brief 挨着第一个控件的第二个控件
     */
    MJBaseWidgetView *_secondView;
}
@end

@implementation MJBasePlistConfigRowView

-(instancetype)initWithFirstView:(NSDictionary *)firstConfig secondView:(NSDictionary *)secondConfig
{
    self = [self init];
    if (self)
    {
        if (!firstConfig)
            return nil;
        
//        if ([firstConfig[kClassName] isEqualToString:NSStringFromClass([MJBaseGridView class])])
//        {//如果是表格视图?忽略第二个参数,因为表格视图要单独占一行
//            [self setupGridView:firstConfig];
//            return self;
//        }
        
        _firstView = [[NSClassFromString(firstConfig[kClassName]) alloc]
                      initWithConfigParam:firstConfig];
        _firstView.tag = (self.tag-kRowViewTagBase+1)<<8 | 0;
        [self addSubview:_firstView];
        [_firstView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [_firstView  autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_firstView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:-kHSpace*0.5]];
        
        if (secondConfig)
        {
            _secondView = [[NSClassFromString(secondConfig[kClassName]) alloc]initWithConfigParam:secondConfig];
            _secondView.tag = (self.tag-kRowViewTagBase+1)<<8 | 1;
            [self addSubview:_secondView];
            [_secondView autoPinEdgeToSuperviewEdge:ALEdgeTop];
            [_secondView  autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
            [_secondView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:_firstView];
        }
        
    }
    return self;
}

-(BOOL)checkInputOfAllWidget
{
    if ([[_firstView configParam][kWidgetParam_Required] boolValue])
    {
        if ([self checkWidgetValueisNil:_firstView.value])
        {
            __weak UIScrollView *supview = (UIScrollView*)self.superview;
            if ([supview isKindOfClass:[UIScrollView class]])
                [supview scrollRectToVisible:self.frame animated:YES];

            [_firstView shakeView];
            return NO;
        }
    }
    
    if ([[_secondView configParam][kWidgetParam_Required] boolValue])
    {
        if ([self checkWidgetValueisNil:_secondView.value])
        {
            __weak UIScrollView *supview = (UIScrollView*)self.superview;
            if ([supview isKindOfClass:[UIScrollView class]])
                [supview scrollRectToVisible:self.frame animated:YES];
            
            [_secondView shakeView];
            return NO;
        }
    }
    return YES;
}

-(BOOL)checkWidgetValueisNil:(id)value
{
    NSString *str = value;
    if ([str isKindOfClass:[NSString class]])
    {
        return !str.length;
    }
   
    if ([value isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = value;
        NSString *s = dict[kWidgetValueKey_SelectedTitle];
        if ([s isKindOfClass:[NSString class]] && s.length)
        {
            return NO;
        }
        
    }
    
    if ([value isKindOfClass:[NSArray class]])
    {//表格视图的值
        NSArray *arry = value;
        
        if (arry.count && [arry.firstObject isKindOfClass:[UIImage class]])
        {//PhotoBorwView的value
            return NO;
        }
        
        NSInteger row = 0;
        for (NSArray *rows in arry)
        {
            if ([rows isKindOfClass:[NSArray class]] && rows.count)
            {
                 NSInteger column =0;
                for (NSDictionary *cell in rows)
                {
                    if ([cell isKindOfClass:[NSDictionary class]])
                    {
                        NSString *content = cell[[NSString stringWithFormat:@"%ld:%ld",(long)row,(long)column]];
                        if ([content isKindOfClass:[NSString class]] && !content.length)
                            break;
                    }
                    column++;
                }
                if (column == rows.count)
                {//说明这行数据全部都有,只要一行全部有数据就行(不需要所有行都填)
                    return NO;
                }
            }else if ([rows isKindOfClass:[NSDictionary class]]){
                return NO;
            
            }
            row++;
        }
        return YES;
    }
    
    if ([value isKindOfClass:[UIImage class]])
    {//签名控件的值
        return NO;
    }
    
    return !value;
}



-(void)setTag:(NSInteger)tag
{
    [super setTag:tag];
     _firstView.tag = (tag-kRowViewTagBase+1)<<8 | 0;
    _secondView.tag = (tag-kRowViewTagBase+1)<<8 | 1;
}

-(void)setupGridView:(NSDictionary*)firstConfig
{
    _firstView = [[NSClassFromString(firstConfig[kClassName]) alloc]
                  initWithConfigParam:firstConfig];
    _firstView.tag = (self.tag-kRowViewTagBase+1)<<8 | 0;
    [self addSubview:_firstView];
    [_firstView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
}

-(MJBaseWidgetView *)getWidgetByIndex:(NSInteger)index
{
    MJBaseWidgetView *view = [self viewWithTag:(self.tag-kRowViewTagBase+1)<<8 | index];
    if ([view isKindOfClass:[MJBaseWidgetView class]])
    {
        return view;
    }
    return nil;
}



-(id)getValueByindex:(NSInteger)index
{
    return [self getWidgetByIndex:index].value;
}

/**
 *  @brief 跳转至下一行
 */
-(void)gotoNextResponder
{
    NSArray *subViews = self.superview.subviews;
    if (subViews.count)
    {
        NSInteger index=  [subViews indexOfObject:self];
        if (subViews.count-1 > index)
        {
            for (NSInteger i=index+1;subViews.count > i; i++)
            {//从下一个开始
                typeof(self) next = subViews[i];
                if ([next isKindOfClass:[self class]])
                {
                    if ([next canBecomeFirstResponder])
                    {
                        [next becomeFirstResponder];
                        return;
                    }
                }
            }
        }
    }
}


-(CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX( (_firstView.configParam[kWidgetParam_Height]?[_firstView.configParam[kWidgetParam_Height] integerValue]:_firstView.intrinsicContentSize.height),  (_secondView.configParam[kWidgetParam_Height]?[_secondView.configParam[kWidgetParam_Height] integerValue]:_secondView.intrinsicContentSize.height)));
}

-(BOOL)becomeFirstResponder
{
    if ([_firstView canBecomeFirstResponder])
    {
        return  [_firstView becomeFirstResponder];
    }
    return  [_secondView becomeFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
    return [_firstView canBecomeFirstResponder] || [_secondView canBecomeFirstResponder];
}


@end
