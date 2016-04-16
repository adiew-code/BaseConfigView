//
//  MJCheckingTextFiled.m
//  MJNSFA
//
//  Created by yang on 16/4/11.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJCheckingTextFiled.h"
#import "MJTextField.h"

#define kSeperator @" / "
#define kWidthOffset (5)

@interface MJCheckingTextFiled ()<UITextFieldDelegate>

@property (nonatomic,strong)UILabel *label;

@end

@implementation MJCheckingTextFiled

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width/2 + kWidthOffset, self.height)];
        _label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _label.textAlignment = NSTextAlignmentRight;
        _label.userInteractionEnabled = YES;
        _label.font = [UIFont systemFontOfSize:15];
        [self addSubview:_label];
//        _label.backgroundColor = [UIColor redColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [_label addGestureRecognizer:tap];
        
        _textField = [[MJTextField alloc] initWithFrame:CGRectMake(_label.right, 0, self.width/2 - kWidthOffset, self.height)];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.textColor = [UIColor redColor];
        _textField.font = [UIFont systemFontOfSize:15];
        [self addSubview:_textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:_textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:_textField];
        
//        _textField.backgroundColor = [UIColor yellowColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.label.frame = CGRectMake(0, 0, self.width/2 + kWidthOffset, self.height);
    self.textField.frame = CGRectMake(_label.right, 0, self.width/2 - kWidthOffset, self.height);
}

- (void)setFont:(UIFont *)font
{
    _label.font = font;
    _textField.font = font;
}

- (void)tapped
{
    if (![_textField isFirstResponder]) {
        [_textField becomeFirstResponder];
    }
}

- (void)setValue:(NSString *)value
{
    NSArray *valueArray = [value componentsSeparatedByString:@","];
    if ([valueArray count] == 2) {
        self.label.text = [valueArray firstObject];
        self.textField.text = valueArray[1];
    }else if ([valueArray count] == 1) {
        self.textField.text = [valueArray firstObject];
    }
    
    if ([self.textField.text length] > 0) {
        if (![self.label.text hasSuffix:kSeperator]) {
            if (!self.label.text) {
                self.label.text = @"";
            }
            self.label.text = [self.label.text stringByAppendingString:kSeperator];
        }
    }
    
}

- (NSString *)getValue
{
    return self.textField.text;
}

- (NSArray *)getAllValue
{
    NSString *labelStr = [NSString stringNotNilWithValue:self.label.text];
    NSString *textFiledStr = [NSString stringNotNilWithValue:self.textField.text];
    return @[labelStr, textFiledStr];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(NSNotification *)notification
{
    if (![self.label.text hasSuffix:kSeperator]) {
        if (!self.label.text) {
            self.label.text = @"";
        }
        self.label.text = [self.label.text stringByAppendingString:kSeperator];
    }
}

- (void)textFieldDidEndEditing:(NSNotification *)notification
{
    if ([self.label.text hasSuffix:kSeperator]) {
        if (!self.textField.text || [self.textField.text length] == 0) {
            self.label.text = [self.label.text stringByReplacingOccurrencesOfString:kSeperator withString:@""];
        }
        
    }
}


@end
