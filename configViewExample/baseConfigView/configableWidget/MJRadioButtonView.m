//
//  MJRadioButtonView.m
//  MJNSFA
//
//  Created by weida on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJRadioButtonView.h"

@interface MJRadioButtonView ()
{
    UILabel   *_textLable;
    NSLayoutConstraint *_widthConstraintLable;
    NSInteger _selectedIndex;//当前选中的是谁？index从0开始
    
    NSInteger _rowCounts;//行数？
}
@end

@implementation MJRadioButtonView

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
    [_textLable autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
    //[_textLable autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, 8, 0, 0) excludingEdge:ALEdgeTrailing];
    CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];
    if (width)
    {
        _widthConstraintLable = [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    
    NSArray *dataSource = self.configParam[kWidgetParam_DataSource];
    
    _selectedIndex = NSIntegerMax;
//    _selectedIndex =[self.configParam[kWidgetParam_PlaceHolder] integerValue];//默认选中谁?
   
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
    NSInteger axisH = 0;
    for (int i=0; i<dataSource.count; i++)
    {
        UIButton * btn= [self newButtonWithTitle:dataSource[i] tag:i+1];
        [self addSubview:btn];
        [btn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:last withOffset:((last == _textLable)?[self.configParam[kWidgetParam_Horizontaloffset] integerValue]:0)];
        [btn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_textLable withOffset:axisH];
        
        last = btn;
        if (((i+1)%num) == 0)//一行的最后一个?
        {
            last = _textLable;
            axisH += super.intrinsicContentSize.height;
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
    [btn setImage:[UIImage imageNamed:@"selected_no_radio"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"selected_yes_radio"] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"selected_no_radio_disabled"] forState:UIControlStateDisabled];
    if (!enable && _selectedIndex==tag-1)
    {
         [btn setImage:[UIImage imageNamed:@"selected_yes_radio_disabled"] forState:UIControlStateDisabled];
    }else
    {
        btn.selected  = _selectedIndex==tag-1;
    }
    btn.enabled = enable;
    
    return btn;
}

-(void)btnCLick:(UIButton *)sender
{
    sender.selected = YES;
    _selectedIndex = sender.tag-1;
    for (UIButton *btn in self.subviews)
    {
        if ([btn isKindOfClass:[UIButton class]] && ![btn isEqual:sender])
        {
            btn.selected = NO;
        }
    }
    
    [self valueDidChanged];
}

- (void)setSelectionWithValue:(NSString *)value
{
    BOOL none = NO;
    for (UIButton *btn in self.subviews)
    {
        if ([btn isKindOfClass:[UIButton class]])
        {
            if ([value isKindOfClass:[NSString class]])
            {
                if ([btn.titleLabel.text isEqualToString:value])
                {
                    none = YES;
                    btn.selected = YES;
                    _selectedIndex = btn.tag - 1;
                }else {
                    btn.selected = NO;
                }
            }else if ([value isKindOfClass:[NSNumber class]])
            {
                if (btn.tag-1 == [value integerValue])
                {
                    none = YES;
                    btn.selected = YES;
                    _selectedIndex = btn.tag - 1;
                }else {
                    btn.selected = NO;
                }
            }else
            {//无选中
                btn.selected = NO;
            }
        }
    }
    
    if (!none)
    {//设置无选中状态
        _selectedIndex = NSIntegerMax;
    }
}



-(id)value
{
    UIButton *btn = [self viewWithTag:_selectedIndex+1];
    if ([btn isKindOfClass:[UIButton class]])
    {
        return @{kWidgetValueKey_SelectedIndex:@(_selectedIndex),
                 kWidgetValueKey_SelectedTitle:btn.titleLabel.text};
    }
    return nil;
}

-(void)setConfigParam:(NSDictionary *)configParam
{
    [super setConfigParam:configParam];
    
    if (configParam[kWidgetParam_LableWidth])
    {
        CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];//Lable 的宽度固定吗？
        if (width)
        {
            [_textLable removeConstraint:_widthConstraintLable];
            _widthConstraintLable =  [_textLable autoSetDimension:ALDimensionWidth toSize:width];
        }
    }
    
    if (configParam[kWidgetParam_currentSelected])
    {
        [self setSelectionWithValue:configParam[kWidgetParam_currentSelected]];
    }

    BOOL enable =  ([self.configParam[kWidgetParam_Enable] boolValue]);
    for (UIButton *btn in self.subviews)
    {
        if ([btn isKindOfClass:[UIButton class]])
        {
            [btn setImage:[UIImage imageNamed:@"selected_no_radio_disabled"] forState:UIControlStateDisabled];
            if (!enable)
            {
                if (btn.isSelected)
                {
                    btn.selected = NO;
                   [btn setImage:[UIImage imageNamed:@"selected_yes_radio_disabled"] forState:UIControlStateDisabled];
                }
            }else
            {
                btn.selected = (_selectedIndex+1)==btn.tag;
            }            
            btn.enabled = enable;
        }
    }
    
    if (configParam[kWidgetParam_Lable] || configParam[kWidgetParam_Required])
    {
        NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:self.configParam[kWidgetParam_Lable] attributes:nil];
        if ([self.configParam[kWidgetParam_Required] boolValue])
        {
            [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
        }
        _textLable.attributedText = attribute;
    }
}

-(CGSize)intrinsicContentSize
{
    CGSize size =  [super intrinsicContentSize];
    size.height *= _rowCounts;
    size.height += [self.configParam[kWidgetParam_MinHeight]integerValue];
    return size;
}


@end
