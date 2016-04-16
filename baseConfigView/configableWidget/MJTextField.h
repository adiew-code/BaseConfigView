//
//  MJTextField.h
//  MJNSFA
//
//  Created by heju on 16/3/23.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJTextField : UITextField {
    int calling_count;
    BOOL isShow;
     float interval;
}

@property (nonatomic,strong)NSString *iRow;
@property (nonatomic,strong)NSString *iColumn;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSString *maxValue;
@property (nonatomic,strong)NSString *minValue;


- (BOOL)shouldReplacementString:(NSString * )string inRange:(NSRange)range;

- (id)initWithFrame:(CGRect)frame;

@end
