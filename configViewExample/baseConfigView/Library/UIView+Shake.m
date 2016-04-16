//
//  UIView+Shake.m
//  MJNSFA
//
//  Created by weida on 16/4/8.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "UIView+Shake.h"

@implementation UIView (Shake)

-(void)shakeView
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    CALayer *lbl = [self layer];
    lbl.cornerRadius = 4;
    lbl.borderWidth = 1.4;
    lbl.borderColor = [UIColor redColor].CGColor;
    CGPoint posLbl = [lbl position];
    CGPoint y = CGPointMake(posLbl.x-10, posLbl.y);
    CGPoint x = CGPointMake(posLbl.x+10, posLbl.y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [lbl addAnimation:animation forKey:nil];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       [UIView animateKeyframesWithDuration:1 delay:0 options:UIViewKeyframeAnimationOptionAutoreverse animations:^
                        {
                            lbl.cornerRadius = 0;
                            lbl.borderWidth  = 0;
                            lbl.borderColor = [UIColor clearColor].CGColor;
                        } completion:nil];
                   });
}
@end
