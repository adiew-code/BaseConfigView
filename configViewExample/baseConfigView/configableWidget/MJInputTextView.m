//
//  WSInputTextView.m
//  hh
//
//  Created by weida on 16/1/27.
//  Copyright © 2016年 weida. All rights reserved.
//

#import "MJInputTextView.h"
#import "UIView+TTCategory.h"
#import "AppDelegate.h"


#define kApplicationDelegate  ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define kApplicationWindow    [kApplicationDelegate window]
#define kApplicationRootControllerView    [kApplicationDelegate window].rootViewController.view
#define kInputBottomInsetWithKeyBoard  (10)
#define kTopInset          (8)
#define kTraingInset       (2)

@interface MJInputTextView ()<UITextViewDelegate>
{
    UILabel *_placeHolder;
    UILabel *_textLable;
    UITextView *_textView;
    
    NSLayoutConstraint *_widthConstraintLable;
}

/**
 *  @brief 自身高度
 */
@property(nonatomic,assign)CGFloat height;

/**
 *  @brief TextView可以输入的最大字符数
 */
@property(nonatomic,assign)NSInteger maxCount;

@end

@implementation MJInputTextView


- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


-(CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, self.height+[self.configParam[kWidgetParam_MinHeight]integerValue]);
}

-(BOOL)setupSubViews
{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    //调用一次，初始化
    [self height];
    [self maxCount];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(2,kTopInset, 2, kTraingInset);
    
    _textLable = [UILabel newAutoLayoutView];
    _textLable.font = kFont;
    
    NSString *text = self.configParam[kWidgetParam_Lable];
    if ([text isKindOfClass:[NSString class]] && text.length)
    {
        NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:text attributes:nil];
        
        if ([self.configParam[kWidgetParam_Required] boolValue])
        {
            [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
        }
        
        _textLable.attributedText = attribute;
    }
    _textLable.textAlignment = NSTextAlignmentLeft;
    _textLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_textLable];
    [_textLable autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeTrailing];
    [_textLable setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];
    if (width)
    {
        _widthConstraintLable = [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    
    
    _textView = [[UITextView alloc]initForAutoLayout];
    _textView.textAlignment = NSTextAlignmentRight;
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.keyboardType = [self.configParam[kWidgetParam_KeyboardType]integerValue];
    _textView.text            = self.configParam[kWidgetParam_Text];
    _textView.scrollEnabled = NO;
    _textView.editable       =  [self.configParam[kWidgetParam_Enable] boolValue];
    _textView.dataDetectorTypes = UIDataDetectorTypeNone;
    _textView.scrollsToTop = NO;
    _textView.layer.borderWidth = 0.8;
    if (_textView.editable)
    {
        _textView.layer.borderColor = [UIColor grayColor].CGColor;
    }else
    {
         _textView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    _textView.layer.cornerRadius = 4;
    _textView.returnKeyType = UIReturnKeyNext;
    _textView.font = kFont;
    [self addSubview:_textView];
    [_textView autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeLeading];
    [_textView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_textLable withOffset:[self.configParam[kWidgetParam_Horizontaloffset] integerValue]+4];
    
    _placeHolder = [UILabel newAutoLayoutView];
    _placeHolder.backgroundColor = [UIColor clearColor];
    _placeHolder.textAlignment = NSTextAlignmentRight;
    _placeHolder.textColor = [UIColor grayColor];
    _placeHolder.font = _textView.font;
    _placeHolder.numberOfLines = 0;
    _placeHolder.hidden = _textView.text.length;
    _placeHolder.text = self.configParam[kWidgetParam_PlaceHolder];
    [self addSubview:_placeHolder];
    [_placeHolder autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:_textView withOffset:-kTraingInset-3];
    [_placeHolder autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_textView withOffset:kTopInset];
    
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _placeHolder.preferredMaxLayoutWidth = _textView.width-10;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [[self viewController].view endEditing:YES];
}


#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self valueWillChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    return YES;
}

-(void)keyboardChange:(NSNotification *)notification
{
    if (![self isFirstResponder])
        return;
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGPoint screenPoint = [self convertPoint:self.frame.origin toView:kApplicationRootControllerView];
    CGFloat self_bottom = screenPoint.y + self.height;
    CGFloat  _screen_will_move_y = (self_bottom + keyboardRect.size.height) - kApplicationWindow.height;
    if (_screen_will_move_y > 0)
    {
        __weak  UIView *view = [[self viewController]view];
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeView" context:nil];
        [UIView setAnimationDuration:animationDuration];
        view.transform = CGAffineTransformMakeTranslation(0, -(_screen_will_move_y + kInputBottomInsetWithKeyBoard));
        [UIView commitAnimations];
    }
}



-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    __weak  UIView *view = [[self viewController]view];
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    view.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    return YES;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""])
    {//允许删除
        return YES;
    }
    if (textView.returnKeyType == UIReturnKeyNext && [text isEqualToString:@"\n"])
    {//点击了Next
        [self gotoNextResponder];
        return NO;
    }
    
    if ([self.configParam[kWidgetParam_InputNumberOnly] boolValue])
    {
        NSScanner* scan = [NSScanner scannerWithString:text];
        int val;
        if (!([scan scanInt:&val] && [scan isAtEnd]))
            return NO;
        
    }
    
    if ([[[UITextInputMode currentInputMode ]primaryLanguage] isEqualToString:@"emoji"]) {
        return NO;
    }
    
    return textView.text.length + text.length-range.length <= self.maxCount;
}


- (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
            
         }
     }];
    return isEomji;
}


-(void)textViewDidChange:(UITextView *)textView
{
    _placeHolder.hidden = textView.text.length;
    
    CGSize size =  [textView sizeThatFits:CGSizeMake(textView.contentSize.width, 0)];
    
    if (self.height != size.height)
    {
        self.height = size.height;
        [self.superview invalidateIntrinsicContentSize];//MJStoresDetailRowView need this
    }

    [self valueDidChanged];
}

/**
 *  @brief 用户键盘点击了下一个，跳转至下一个输入框
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
    
    [self textViewShouldEndEditing:_textView];
    [self resignFirstResponder];
    
    if ([self.superview respondsToSelector:@selector(gotoNextResponder)])
    {
        [self.superview performSelector:@selector(gotoNextResponder) withObject:nil];
    }

}

#pragma mark - Getter Method

-(id)value
{
    if ([self.configParam[kWidgetParam_Enable]boolValue])
    {
        return _textView.text;
    }else
    {
        if (_textView.text.length)
        {
            return _textView.text;
        }else
        {
            return _placeHolder.text;
        }
    }
}


-(NSInteger)maxCount
{
    NSInteger count = [self.configParam[kWidgetParam_InputMaxCount] integerValue];//用户是否配置了此参数?
    if (count)
    {
        _maxCount = count;
        return _maxCount;
    }
    
    if (!_maxCount) {
        _maxCount = NSIntegerMax;
    }
    
    return _maxCount;
}


-(CGFloat)height
{
    if (!_height)
    {
        _height = kDefaultHeight;
    }
    return _height;
}

/**
 *  @brief 根据配置参数重新刷新界面显示
 *
 *  @param configParam 配置的参数信息
 */
-(void)setConfigParam:(NSDictionary *)configParam
{
    [super setConfigParam:configParam];
    
    [self maxCount];
    
    if (configParam[kWidgetParam_Enable])
    {
        _textView.editable = [self.configParam[kWidgetParam_Enable] boolValue];
        if (_textView.editable)
            _textView.layer.borderColor = [UIColor grayColor].CGColor;
        else
            _textView.layer.borderColor = [UIColor clearColor].CGColor;
        
    }
    
    if (configParam[kWidgetParam_LableWidth])
    {
        CGFloat width = [configParam[kWidgetParam_LableWidth] floatValue];//Lable 的宽度固定吗？
        if (width)
        {
            [_textLable removeConstraint:_widthConstraintLable];
            _widthConstraintLable =  [_textLable autoSetDimension:ALDimensionWidth toSize:width];
        }
    }
    
    if (configParam[kWidgetParam_PlaceHolder])
    {
        _placeHolder.text = self.configParam[kWidgetParam_PlaceHolder];
        
//        if (!_textView.editable &&  !_textView.text.length)
//        {
//            CGFloat height = _placeHolder.bottom;
//            if (height>0)
//            {
//                self.height =height;
//                 [self.superview invalidateIntrinsicContentSize];
//            }
//            
//        }
    }
   
    
    if (configParam[kWidgetParam_Text])
    {
        _textView.text    = configParam[kWidgetParam_Text];
        [self textViewDidChange:_textView];
    }
    
    if (configParam[kWidgetParam_KeyboardType])
        _textView.keyboardType = [self.configParam[kWidgetParam_KeyboardType]integerValue];
   
   
    if (configParam[kWidgetParam_Lable] || configParam[kWidgetParam_Required])
    {
        NSString *text = self.configParam[kWidgetParam_Lable];
        if ([text isKindOfClass:[NSString class]] && text.length)
        {
            NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:text attributes:nil];
            if ([self.configParam[kWidgetParam_Required] boolValue])
                [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
            
            _textLable.attributedText = attribute;
        }
    }
}

-(BOOL)isFirstResponder
{
    return [_textView isFirstResponder];
}


-(BOOL)becomeFirstResponder
{
    return  [_textView becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
    return  [_textView resignFirstResponder];
}

-(BOOL)canBecomeFirstResponder
{
    return [self.configParam[kWidgetParam_Enable] boolValue];
}

@end
