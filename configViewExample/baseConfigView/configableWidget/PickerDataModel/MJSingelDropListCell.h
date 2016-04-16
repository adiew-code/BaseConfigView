//
//  MJSingelDropListCell.h
//  MJNSFA
//
//  Created by zhiqing on 16/1/29.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I_W_OptionDataItem.h"

@interface MJSingelDropListCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *markImageView;

@property(nonatomic,strong) NSObject<I_W_OptionDataItem> *dataItem;

- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem isSelected:(BOOL)isSelected;


@property(nonatomic,assign) float cornerRadius;

@property(nonatomic,assign) BOOL isSelect;

@property(nonatomic,assign) BOOL imgIsShow;
@end
