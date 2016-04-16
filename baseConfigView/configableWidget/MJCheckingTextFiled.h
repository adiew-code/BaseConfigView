//
//  MJCheckingTextFiled.h
//  MJNSFA
//
//  Created by yang on 16/4/11.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJTextField;

@interface MJCheckingTextFiled : UIView

@property (nonatomic,strong)NSString *iRow;
@property (nonatomic,strong)NSString *iColumn;
@property (nonatomic,strong)NSString *type;

@property (nonatomic,strong)MJTextField *textField;

- (void)setFont:(UIFont *)font;

- (void)setValue:(NSString *)value;
- (NSString *)getValue;

- (NSArray *)getAllValue;

@end
