//
//  MJSignatureView.m
//  MJNSFA
//
//  Created by weida on 16/2/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJSignatureView.h"
#import "WSSignatureView.h"

#define kTextColor              ([UIColor colorWithRed:0.118 green:0.584 blue:0.729 alpha:1])
#define kSizeSignImage          (CGSizeMake(100, 75))
#define kTagSignView            (111)
#define kAnnimateTime           (0.5)

@interface MJSignatureView ()
{
    /**
     *  @brief 用户签名后，形成的略缩图
     */
    UIImageView *_signImageView;
    
    /**
     *  @brief 用户签名的视图
     */
    UIView      *_signBoardView;
    
    UIView      *_maskView;
    
    CATransform3D _transfrom;
}
@end


@implementation MJSignatureView

-(CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, kSizeSignImage.height+20+[self.configParam[kWidgetParam_MinHeight]integerValue]);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_signBoardView)
    {//非第一次
        
        if (_signBoardView.hidden)
        {
            _signBoardView.hidden = NO;
            _maskView.hidden = NO;
            
            [UIView animateWithDuration:kAnnimateTime animations:^
             {
                 _maskView.alpha = 0.5;
                 _signBoardView.layer.transform = CATransform3DIdentity;
             } completion:^(BOOL finished) {
                 [self valueWillChanged];
             }];
        }else
        {
            [self Dismiss];
        }
    }else
    {//第一次显示
        
        [self valueWillChanged];
        
        UIWindow * window = [[[UIApplication sharedApplication] windows] firstObject];
        UIView * rootView = window.rootViewController.view;
        
        _maskView = [UIView newAutoLayoutView];
        _maskView.userInteractionEnabled = YES;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Dismiss)]];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;
        [rootView addSubview:_maskView];
        [_maskView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        CGRect sourceRect = [_signImageView convertRect:_signImageView.bounds toView:rootView];
        CGFloat width  = rootView.width*0.65;
        CGFloat height = width*(_signImageView.height/_signImageView.width);
        CGRect frame = CGRectMake((rootView.width-width)/2, (rootView.height-height)/2, width, height);
        _signBoardView = [[UIView alloc]initWithFrame:frame];
        _signBoardView.backgroundColor = [UIColor whiteColor];
        _transfrom = CATransform3DConcat(CATransform3DMakeScale(sourceRect.size.width/width,sourceRect.size.height/height, 1), CATransform3DMakeTranslation(+_signImageView.left-_signBoardView.left-_signImageView.width,-_signImageView.centerY+_signBoardView.centerY, 0));
         _signBoardView.layer.transform = _transfrom;
        _signBoardView.layer.borderColor = [UIColor grayColor].CGColor;
        _signBoardView.layer.borderWidth = 0.6;
        _signBoardView.userInteractionEnabled = YES;
        [rootView addSubview:_signBoardView];
        
        /**
         *  @brief 增加删除按钮
         */
        UIButton *deleteBtn = [UIButton newAutoLayoutView];
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:kTextColor forState:UIControlStateNormal];
        [_signBoardView addSubview:deleteBtn];
        [deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
        [deleteBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:25];
        
        /**
         *  @brief 增加保存按钮
         */
        UIButton *saveBtn = [UIButton newAutoLayoutView];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:kTextColor forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        [_signBoardView addSubview:saveBtn];
        [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:15];
        [saveBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:25];
        
        WSSignatureView *signatureView = [[WSSignatureView alloc]initForAutoLayout];
        signatureView.tag = kTagSignView;
         [deleteBtn addTarget:signatureView action:@selector(erase) forControlEvents:UIControlEventTouchUpInside];
        signatureView.signatureImage = _signImageView.image;
        [_signBoardView addSubview:signatureView];
        [signatureView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_signBoardView bringSubviewToFront:deleteBtn];
        [_signBoardView bringSubviewToFront:saveBtn];
        
        [UIView animateWithDuration:kAnnimateTime animations:^
        {
            _maskView.alpha = 0.5;
            _signBoardView.layer.transform = CATransform3DIdentity;
            deleteBtn.hidden = NO;
            saveBtn.hidden = NO;
        } completion:^(BOOL finished) {
            
        }];

    }
}

-(void)save
{
    WSSignatureView *signatureView = [_signBoardView viewWithTag:kTagSignView];
    _signImageView.image =  signatureView.signatureImage;
    _signImageView.hidden = YES;
   
    [self Dismiss];
    
    [self valueDidChanged];
}

/**
 *  @brief 点击隐藏视图
 *
 */
-(void)Dismiss
{
    _signBoardView.hidden = NO;
    _maskView.hidden = NO;
    
    [UIView animateWithDuration:kAnnimateTime animations:^
     {
         _maskView.alpha = 0;
         _signBoardView.layer.transform = _transfrom;
     } completion:^(BOOL finished)
    {
        _signBoardView.hidden = YES;
        _maskView.hidden = YES;
         _signImageView.hidden = NO;
     }];
}



-(BOOL)setupSubViews
{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    UILabel *lable = [UILabel newAutoLayoutView];
    lable.backgroundColor = [UIColor clearColor];
    lable.text = @"签名";
    lable.textColor = kTextColor;
    [self addSubview:lable];
    
    [lable autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [lable autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    
    _signImageView = [UIImageView newAutoLayoutView];
    _signImageView.contentMode = UIViewContentModeScaleToFill;
    _signImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_signImageView];
    [_signImageView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lable withOffset:40];
    [_signImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:lable];
    [_signImageView autoSetDimensionsToSize:kSizeSignImage];
    
    return YES;
}

-(void)dealloc
{
    [_maskView removeFromSuperview];
    _maskView = nil;
    
    [_signBoardView removeFromSuperview];
    _signBoardView = nil;
}

-(id)value
{
    return _signImageView.image;
}

@end
