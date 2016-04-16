//
//  MJMultipleChoiceView.m
//  MJNSFA
//
//  Created by weida on 16/2/4.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJMultipleChoiceView.h"

#define kTopInset     (12)

@interface MJMultipleChoiceView ()
{
    UILabel   *_textLable;
    NSLayoutConstraint *_widthConstraintLable;
    NSInteger _rowCounts;//行数？
    CGFloat  _singleLineHeight;
}
@end

@implementation MJMultipleChoiceView

-(BOOL)setupSubViews
{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    _textLable = [UILabel newAutoLayoutView];
    _textLable.font = kFont;

    NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:self.configParam[kWidgetParam_Lable] attributes:nil];
    
    if ([self.configParam[kWidgetParam_Required] boolValue])
    {
        [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
    }
    
    _textLable.attributedText = attribute;
    
    [self addSubview:_textLable];
    [_textLable autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:8];
    [_textLable autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTopInset];
    CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];
    if (width)
    {
        _widthConstraintLable = [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    
    NSArray *dataSource = self.configParam[kWidgetParam_DataSource];
    
    _rowCounts = 1;//默认在一行上显示所有选项
    
    NSInteger num = [self.configParam[kWidgetParam_CountOfOneRow] integerValue];//一行显示几个选项?
    if (num)
    {
        _rowCounts = dataSource.count/num + ((BOOL)(dataSource.count%num));//如果一行显示num个选项,那么需要几行?
    }else
    {//0表示，用户没设置,默认所有选项在全部在一行上显示
        num = NSIntegerMax;
    }
    
    UIView *last = _textLable;
    NSInteger axisH =0;
    for (int i=0; i<dataSource.count; i++)
    {
        UIButton * btn= [self newButtonWithTitle:dataSource[i] tag:i+1];
        [self addSubview:btn];
        [btn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:last withOffset:last==_textLable?[self.configParam[kWidgetParam_Horizontaloffset] integerValue]:40];
       
        [btn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_textLable withOffset:axisH];
        
        last = btn;
        
        if (!_singleLineHeight)
            _singleLineHeight = [btn.titleLabel.text sizeWithFont:_textLable.font].height;
        
        if (((i+1)%num) == 0)//一行的最后一个?
        {
            last = _textLable;
            axisH += _singleLineHeight +[self.configParam[kWidgetParam_VerticalRowInset]integerValue];
        }
    }
    
    return YES;
}

-(UIButton *)newButtonWithTitle:(NSString *)title tag:(NSInteger)tag
{
    BOOL enable =  ([self.configParam[kWidgetParam_Enable] boolValue]);
    UIButton *btn = [UIButton newAutoLayoutView];
    btn.tag = tag;
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.font = _textLable.font;
    [btn addTarget:self action:@selector(btnCLick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"multiple-check_0"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"multiple-check_1"] forState:UIControlStateSelected];
    btn.enabled = enable;
    
    return btn;
}

-(void)btnCLick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    [self valueDidChanged];
}

-(id)value
{
    NSMutableArray *ret = nil;
    
    for (UIButton*btn in self.subviews)
    {
        if ([btn isKindOfClass:[UIButton class]] && btn.selected)
        {
            if (!ret)
                ret = @[].mutableCopy;
            [ret addObject:@{kWidgetValueKey_SelectedIndex:@(btn.tag-1),kWidgetValueKey_SelectedTitle:btn.titleLabel.text}];
        }
    }
    
    return ret;
}


- (void)setSelectionWithValue:(NSArray *)arrys
{
    if ([arrys isKindOfClass:[NSArray class]] && arrys.count)
    {
        for (UIButton*btn in self.subviews)
        {
            if ([btn isKindOfClass:[UIButton class]])
            {
                btn.selected = NO;
                
                for (NSString*title in arrys)
                {
                    if ([title isKindOfClass:[NSString class]])
                    {
                        if ([title isEqualToString:btn.titleLabel.text])
                        {
                            btn.selected = YES;
                        }
                    }
                }
                
            }
        }

    }else
    {//清空所有选中状态
        for (UIButton*btn in self.subviews)
        {
            if ([btn isKindOfClass:[UIButton class]])
            {
                btn.selected = NO;
            }
        }

    }
}


-(void)setConfigParam:(NSDictionary *)configParam
{
    [super setConfigParam:configParam];
    
    if (configParam[kWidgetParam_LableWidth])
    {
        CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];//Lable 的宽度固定吗？
        [_textLable removeConstraint:_widthConstraintLable];
        _widthConstraintLable =  [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    
    if (configParam[kWidgetParam_currentSelected])
    {
        [self setSelectionWithValue:configParam[kWidgetParam_currentSelected]];
    }
    
    
    if (configParam[kWidgetParam_Enable])
    {
        BOOL enable =  ([self.configParam[kWidgetParam_Enable] boolValue]);
        for (UIButton *btn in self.subviews)
        {   if ([btn isKindOfClass:[UIButton class]])
            {
                btn.enabled = enable;
            }
        }
    }
    
    if (configParam[kWidgetParam_Lable] || configParam[kWidgetParam_Required])
    {
        NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:self.configParam[kWidgetParam_Lable] attributes:nil];
        if ([self.configParam[kWidgetParam_Required] boolValue])
            [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
        
        _textLable.attributedText = attribute;
    }
}

-(CGSize)intrinsicContentSize
{
    CGSize size = super.intrinsicContentSize;    
    size.height = _rowCounts *_singleLineHeight+kTopInset +[self.configParam[kWidgetParam_VerticalRowInset]integerValue]*(_rowCounts-1);
    size.height += +[self.configParam[kWidgetParam_MinHeight]integerValue];
    return size;
}

@end
