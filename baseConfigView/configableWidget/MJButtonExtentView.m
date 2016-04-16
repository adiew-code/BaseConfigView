//
//  MJButtonExtentView.m
//  MJNSFA
//
//  Created by user on 16/4/1.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//
#define kTopInset          (8)
#define kTraingInset       (2)
#define kLoginButtonBackgroundColor ([UIColor colorWithRed:28.0/255.0 green:134.0/255.0 blue:238.0/255.0 alpha:1.0])
#define kButtonFont ([UIFont systemFontOfSize:16])
#import "MJButtonExtentView.h"
@interface MJButtonExtentView()
{
    UILabel *_textLable;
    UIButton *_detailButton;
    NSLayoutConstraint *_widthConstraintLable;
}
@end
@implementation MJButtonExtentView
-(BOOL)setupSubViews
{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    UIEdgeInsets inset = UIEdgeInsetsMake(2,kTopInset, 2, kTraingInset);
    
    _textLable = [UILabel newAutoLayoutView];
    _textLable.font = kFont;
    
    NSString *text = self.configParam[kWidgetParam_Lable];
    if ([text isKindOfClass:[NSString class]] && text.length)
    {
        NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:text attributes:nil];
        _textLable.attributedText = attribute;
    }
    _textLable.textAlignment = NSTextAlignmentLeft;
    _textLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_textLable];
    
    [_textLable autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeTrailing];
    [_textLable setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];//Lable 的宽度固定吗？
    if (width)
    {
        [_textLable removeConstraint:_widthConstraintLable];
        _widthConstraintLable =  [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    
     _detailButton= [[UIButton alloc] initForAutoLayout];
    [_detailButton setTitle:@"详情>>" forState:UIControlStateNormal];
    [_detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_detailButton setBackgroundColor:kLoginButtonBackgroundColor];
    _detailButton.layer.cornerRadius = 2;
    _detailButton.titleLabel.font = kButtonFont;
    [_detailButton addTarget:self action:@selector(clickAction)forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_detailButton];
    //[_detailButton autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeLeading];
   [_detailButton autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_textLable withOffset:4];
    [_detailButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_textLable withOffset:10];
    [_detailButton autoSetDimension:ALDimensionWidth toSize:60];
    
    return YES;
}
-(void)clickAction{
    [self valueDidChanged];
}
@end
