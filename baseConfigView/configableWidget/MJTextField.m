//
//  MJTextField.m
//  MJNSFA
//
//  Created by heju on 16/3/23.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJTextField.h"

#import "MJAppDelegate.h"

#import <objc/runtime.h>

#import "BaseViewController.h"

#import "MJBaseGridView.h"

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)? NO:YES)

static CGFloat firstInterval = 0;
static UIScrollView *moveView;


@interface MJTextField ()

@property (nonatomic,assign) CGFloat screen_will_move_y;
@property (nonatomic,strong) UIView *moveView;

@end

@implementation MJTextField

- (id)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        
        //增加监听，当键盘出现或改变时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        //增加监听，当键退出时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

        return self;
    }
    return nil;
}

- (BOOL)shouldReplacementString:(NSString *)string inRange:(NSRange)range {
    //判断是否为数字
    BOOL isReplace = YES;
    if ([self.type isEqualToString:@"N"]) {
        for (int i = 0; i < string.length; i++) {
            unichar c = [string characterAtIndex:i];
            if (!isdigit(c)) {
                isReplace = NO;
            }
        }
        
        // 支持显示负数与小数
        if (!isReplace && ([string isEqualToString:@"."] || [string isEqualToString:@"-"])) {
            isReplace = YES;
        }
    }else if ([self.type isEqualToString:@"INT"]) {
        for (int i = 0; i < string.length; i++) {
            unichar c = [string characterAtIndex:i];
            if (!isdigit(c)) {
                isReplace = NO;
                
                /*
                NSString *title = @"温馨提示!";
                NSString *message = @"只能填写数字";
                NSString *cancel = @"取消";
                NSString *ok = @"确定";
                if (IOS8_OR_LATER) {
                    UIAlertController *alterControl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                         //
                    }];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        //
                    }];
                    [alterControl addAction:cancelAction];
                    [alterControl addAction:okAction];
                    [[[self viewController] navigationController] presentViewController:alterControl animated:YES completion:^{
                        
                    }];
                    
                    
                } else {
                    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:ok, nil];
                    [alterView show];
                }
                 */
                
                
            }
        }
    }
    
    if (isReplace) {
        if ([self.maxValue length] > 0 || [self.minValue length] > 0) {
            NSString *allString = [self.text stringByReplacingCharactersInRange:range withString:string];
            if ([allString doubleValue] > [self.maxValue doubleValue]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kApplicationWindow withText:[NSString stringWithFormat:@"最大只能输入%@", self.maxValue] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                hud.yOffset = -100;
                isReplace = NO;
            }
            
            if (isReplace) {
                if ([allString doubleValue] < [self.minValue doubleValue]) {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kApplicationWindow withText:[NSString stringWithFormat:@"最小只能输入%@", self.minValue] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    hud.yOffset = -100;
                    isReplace = NO;
                }
            }
            
        }
    }
    
    return isReplace;
}


-(void)keyboardWillShow:(NSNotification *)notification {
    /*
     获取键盘的高度
     */
    if (![self isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    CGPoint screenPoint = [self convertPoint:self.frame.origin toView:kApplicationRootControllerView];
    /*点击控件的底部y坐标*/
    CGFloat self_bottom = screenPoint.y + self.height;
    _screen_will_move_y = (self_bottom + keyboardRect.size.height) - kApplicationWindow.height;
    
    if (_screen_will_move_y > 0) {
        firstInterval = _screen_will_move_y;
        _moveView = [[self viewController] view];
        [self moveView:_moveView offset:- firstInterval];
    }
}



- (void)keyboardWillHide:(NSNotification *)notification {
    if (![self isFirstResponder]) {
        return;
    }
    if (firstInterval > 0 ) {
        UIView *view = [[self viewController] view];
        CGPoint viewPoint = [view origin];
        viewPoint.y = 0+64;
        view.origin =viewPoint;
    }
}

-(void)moveView:(UIView *)view offset:(CGFloat)offset{
    
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = view.frame;
    frame.origin.y +=offset;
    view.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    view.frame = frame;
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end

