//
//  MJBasePlistConfigView.m
//  MJNSFA
//
//  Created by weida on 16/3/7.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJBasePlistConfigView.h"
#import "PureLayout.h"
#import "MJBasePlistConfigRowView.h"
#import "NSArray+safety.h"
#import "MJBasePlistConfigController.h"

#define kVSpace     (8) //垂直间距
#define kHSpace     (20)


@interface MJBasePlistConfigView ()
{
    BOOL _hasSetup;
}

/**
 *  @brief 装了所有的行
 */
@property(nonatomic,strong) NSMutableArray *rowViewsArry;

@property (nonatomic, weak) id<MJBaseWidgetViewDelegate> widgetDelegate;
@end

@implementation MJBasePlistConfigView

-(instancetype)initWithDelegate:(__weak id<MJBasePlistConfigViewDelegate>)delegate
{
    self.delegateConfig = delegate;
    self = [self init];
    return self;
}

-(instancetype)init
{
    self = [super init];
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

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews
{
    if (_hasSetup)
        return;
    
    _hasSetup = YES;
    self.showsVerticalScrollIndicator = YES;
    self.alwaysBounceVertical = YES;//必须加上
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    NSArray* configs = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSStringFromClass(([self.delegateConfig isKindOfClass:[MJBasePlistConfigController class]]?self.delegateConfig:self).class) ofType:@"plist"]];
    
    if (!configs.count)
        return;
    
    id<MJBasePlistConfigViewDelegate>target = [self.delegateConfig respondsToSelector:@selector(rowViewEdgeInsetsAtIndex:)]?self.delegateConfig:self;
    UIView *lastView = nil;
 
    for (NSInteger i=0; i<configs.count; i+=2)
    {//每2个一行
        NSDictionary *first  = [configs objectAtIndexEx:i];
        NSDictionary *second = [configs objectAtIndexEx:i+1];

  
        MJBasePlistConfigRowView *row = [MJBasePlistConfigRowView alloc];
        row.tag = (i/2) +kRowViewTagBase;
        first = [([self.delegateConfig respondsToSelector:@selector(rowViewWillinitRow:Index:configParam:)]?self.delegateConfig:self) rowViewWillinitRow:row.tag-kRowViewTagBase Index:0 configParam:first];
        second = [([self.delegateConfig respondsToSelector:@selector(rowViewWillinitRow:Index:configParam:)]?self.delegateConfig:self) rowViewWillinitRow:row.tag-kRowViewTagBase Index:1 configParam:second];
        row = [row initWithFirstView:first secondView:second];
        [self addSubview:row];
        [self.rowViewsArry addObject:row];
//        [([self.delegateConfig respondsToSelector:@selector(rowViewUpdateAtIndex:FirstWidgetView:SecondWidgetView:)]?self.delegateConfig:self) rowViewUpdateAtIndex:row.tag-kRowViewTagBase FirstWidgetView:(MJBaseWidgetView*)[row.subviews objectAtIndexEx:0]
//                                                                                                                       SecondWidgetView:(MJBaseWidgetView*)[row.subviews objectAtIndexEx:1]];
//        
         UIEdgeInsets inset = [target rowViewEdgeInsetsAtIndex:row.tag-kRowViewTagBase];
        
        if (!lastView)
        {
            [row autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset.top];
        }else
        {
            [row autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:inset.top+[target rowViewEdgeInsetsAtIndex:row.tag-kRowViewTagBase-1].bottom];
        }
        
        [row autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-(inset.left+inset.right)];
        [row autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:inset.left];
        [row autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:inset.right];
        lastView = row;
    }
    [lastView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[target rowViewEdgeInsetsAtIndex:(configs.count-1)/2].bottom];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self reloadData];
    });
}



-(void)insertRowsAt:(NSInteger)row configs:(NSArray*)configs 
{
    if (!configs.count)
        return;
    
    if (row >= self.rowViewsArry.count)//不能越界
        row = self.rowViewsArry.count;
    
    __weak id<MJBasePlistConfigViewDelegate>target = [self.delegateConfig respondsToSelector:@selector(rowViewEdgeInsetsAtIndex:)]?self.delegateConfig:self;
//    dispatch_async(dispatch_get_main_queue(), ^
//    {
    
        UIView  *prev = [self.rowViewsArry objectAtIndexEx:row-1];//[self viewWithTag:row-1+kRowViewTagBase];
        UIView  *next = [self.rowViewsArry objectAtIndexEx:row];//[self viewWithTag:row+kRowViewTagBase];
        
        UIView *firstRowView;
        UIView *lastView = nil;
        for (NSInteger i=0; i<configs.count; i+=2)
        {//每2个一行
            NSDictionary *first  = [configs objectAtIndexEx:i];
            NSDictionary *second = [configs objectAtIndexEx:i+1];
            UIEdgeInsets inset   = [target rowViewEdgeInsetsAtIndex:row+i/2];
            
            MJBasePlistConfigRowView *rowView = [[MJBasePlistConfigRowView alloc]initWithFirstView:first secondView:second];
            
            [self addSubview:rowView];
            [self.rowViewsArry insertObject:rowView atIndex:row+i/2];
            
            if (!i)
                firstRowView = rowView;
            
            
            [rowView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-(inset.left+inset.right)];
            [rowView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:inset.left];
            [rowView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:inset.right];
            
            if (!(prev && [prev isKindOfClass:[MJBasePlistConfigRowView class]]))
            {//则说明要插入在第一行
                if (!lastView)
                {
                    [rowView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:inset.top];
                }else
                {
                    [rowView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:inset.top+[target rowViewEdgeInsetsAtIndex:row+i/2-1].bottom];
                }
            }else
            {
                if (!lastView)
                {
                    NSLayoutConstraint *_bottomConstraint = nil;
                    for (NSLayoutConstraint*contrstaint in self.constraints)
                    {
                        if ((contrstaint.firstItem == prev) && (contrstaint.firstAttribute == NSLayoutAttributeBottom) &&
                            ([contrstaint.secondItem isKindOfClass:[MJBasePlistConfigRowView class]] || contrstaint.secondItem == self))
                        {
                            _bottomConstraint = contrstaint;
                            break;
                        }
                        
                        if ((contrstaint.secondItem == prev) && (contrstaint.secondAttribute == NSLayoutAttributeBottom) &&
                            ([contrstaint.firstItem isKindOfClass:[MJBasePlistConfigRowView class]] || contrstaint.firstItem == self))
                        {
                            _bottomConstraint = contrstaint;
                            break;
                        }
                    }
                    [self removeConstraint:_bottomConstraint];
                    
                    [rowView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:prev withOffset:inset.top+[target rowViewEdgeInsetsAtIndex:row+i/2-1].bottom];
                }else
                {
                    [rowView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:lastView withOffset:inset.top+[target rowViewEdgeInsetsAtIndex:row+i/2-1].bottom];
                }
            }
            
            lastView = rowView;
        }
        
        
        if (next && [next isKindOfClass:[MJBasePlistConfigRowView class]])
        {//有下一个
            //移除next以前和上个视图顶部的约束
            
            NSLayoutConstraint *_TopConstraint = nil;
            for (NSLayoutConstraint*contrstaint in self.constraints)
            {
                if ((contrstaint.secondItem == next) && (contrstaint.secondAttribute == NSLayoutAttributeTop)  &&
                    ([contrstaint.firstItem isKindOfClass:[MJBasePlistConfigRowView class]] || contrstaint.firstItem == self))
                {
                    _TopConstraint = contrstaint;
                    break;
                }
                
                if ((contrstaint.firstItem == next) && (contrstaint.firstAttribute == NSLayoutAttributeTop)  &&
                    ([contrstaint.secondItem isKindOfClass:[MJBasePlistConfigRowView class]] || contrstaint.secondItem == self))
                {
                    _TopConstraint = contrstaint;
                    break;
                }
            }
            [self removeConstraint:_TopConstraint];
            NSInteger index = [self.rowViewsArry indexOfObject:lastView];
            [next autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom  ofView:lastView withOffset:[target rowViewEdgeInsetsAtIndex:index].bottom+[target rowViewEdgeInsetsAtIndex:index+1].top];
        }else
        {
            [lastView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:[target rowViewEdgeInsetsAtIndex:self.rowViewsArry.count-1].bottom];
        }

        [self reInstallallSubRowTag];
        [self setNeedsUpdateConstraints];
//    });
}




-(BOOL)checkInputOfAllWidget
{
    NSArray *subViews = self.subviews;
    for (MJBasePlistConfigRowView*row in subViews)
    {
        if ([row isKindOfClass:[MJBasePlistConfigRowView class]])
        {
            if (![row checkInputOfAllWidget])
                return NO;
        }
    }
    return YES;
}

-(MJBaseWidgetView *)getWidgetByRow:(NSInteger)row Index:(NSInteger)index
{
    MJBasePlistConfigRowView *rowView = (MJBasePlistConfigRowView*)[self viewWithTag:row + kRowViewTagBase];
    if ([rowView isKindOfClass:[MJBasePlistConfigRowView class]])
    {
        return [rowView getWidgetByIndex:index];
    }
    return nil;
}

-(id)getValueByRow:(NSInteger)row Index:(NSInteger)index
{
    return [self getWidgetByRow:row Index:index].value;
}

-(void)reloadData
{
    for (MJBasePlistConfigRowView*row in self.rowViewsArry)
    {
        if ([row isKindOfClass:[MJBasePlistConfigRowView class]])
        {
            [([self.delegateConfig respondsToSelector:@selector(rowViewUpdateAtIndex:FirstWidgetView:SecondWidgetView:)]?self.delegateConfig:self)  rowViewUpdateAtIndex:row.tag-kRowViewTagBase FirstWidgetView:(MJBaseWidgetView*)[row.subviews objectAtIndexEx:0]
                                                                                                                                                        SecondWidgetView:(MJBaseWidgetView*)[row.subviews objectAtIndexEx:1]];
            
        }
    }
}


-(void)reInstallallSubRowTag;
{
    NSInteger i=0;
    for (UIView *sub in self.rowViewsArry)
    {
        sub.tag = kRowViewTagBase+i++;
    }
}

-(void)dealloc
{
    [self.rowViewsArry removeAllObjects];
}


/**
 *  @brief 删除指定的行
 *
 *  @param row 删除的行号. 从0开始
 */
-(void)deleteRowAt:(NSInteger)row
{
    __weak id<MJBasePlistConfigViewDelegate>target = [self.delegateConfig respondsToSelector:@selector(rowViewEdgeInsetsAtIndex:)]?self.delegateConfig:self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        UIView *deleteRow = [self.rowViewsArry objectAtIndexEx:row];//获取将要被删除的那行
        
        if (!(deleteRow && [deleteRow isKindOfClass:[MJBasePlistConfigRowView class]]))
            return;
        
        UIEdgeInsets inset = [target rowViewEdgeInsetsAtIndex:row];
        
        UIView  *prev = [self.rowViewsArry objectAtIndexEx:row-1];
        UIView  *next = [self.rowViewsArry objectAtIndexEx:row+1];
        
        [deleteRow removeFromSuperview];
        [self.rowViewsArry removeObject:deleteRow];
        
        if (!prev)
        {//则说明要删除的这个是第一个
            prev = self;
            if (next)
            {//有下一个
                [next autoPinEdge:ALEdgeTop toEdge:ALEdgeTop  ofView:prev withOffset:inset.top];
                [self reInstallallSubRowTag];
            }
            [self setNeedsUpdateConstraints];
            return;
        }
        
        if ((next && [next isKindOfClass:[MJBasePlistConfigRowView class]]))
        {//上一个有，下一个也有
            [next autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:prev withOffset:inset.top+[target rowViewEdgeInsetsAtIndex:row-1].bottom];
            [self reInstallallSubRowTag];
        }
        
        [self setNeedsUpdateConstraints];
    });
}



#pragma mark - Delegate

-(void)rowViewUpdateAtIndex:(NSInteger)index FirstWidgetView:(MJBaseWidgetView *)firstView SecondWidgetView:(MJBaseWidgetView *)secondView
{
    //Do nothing here ...
}

-(UIEdgeInsets)rowViewEdgeInsetsAtIndex:(NSInteger)row
{
    return UIEdgeInsetsMake(kVSpace,kHSpace, kVSpace,kHSpace);
}

-(NSDictionary *)rowViewWillinitRow:(NSInteger)row Index:(NSInteger)index configParam:(NSDictionary *)configParam
{
    return configParam;//Default
}

#pragma mark - Getter Mehod

-(NSMutableArray *)rowViewsArry
{
    if (_rowViewsArry)
        return _rowViewsArry;
    
    return _rowViewsArry = @[].mutableCopy;
}

@end
