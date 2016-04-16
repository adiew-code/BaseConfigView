//
//  MJSingelDropListCell.m
//  MJNSFA
//
//  Created by zhiqing on 16/1/29.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJSingelDropListCell.h"
#import "PureLayout.h"
@interface MJSingelDropListCell ()

@end


@implementation MJSingelDropListCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.textColor = [UIColor blackColor];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        
        self.markImageView = [[UIImageView alloc] init];
        self.markImageView.image = [UIImage imageNamed:@"menu_xialan_arrow"];
        self.markImageView.contentMode = UIViewContentModeCenter;
        self.markImageView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.markImageView];
        
        return self;

    }
    return nil;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.contentLabel.frame = CGRectMake(12, 0, self.bounds.size.width, self.bounds.size.height);
    self.markImageView.frame = CGRectMake(self.bounds.size.width  - 30 -5, (self.bounds.size.height - 15)/2, 15, 15);
}

- (void)setDataItem:(NSObject<I_W_OptionDataItem> *)dataItem isSelected:(BOOL)isSelected
{
    self.dataItem = dataItem;
    self.contentLabel.text = [dataItem getDataItemName];
    
    [self setSelectedIdentify:isSelected];
}

- (void)setSelectedIdentify:(BOOL)isSelected {
    if (isSelected) {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:12/255.0 green:100/255.0 blue:188/255.0 alpha:1];
        self.contentLabel.textColor = [UIColor whiteColor];
    }
    else{
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentLabel.textColor = [UIColor blackColor];
    }
}
@end
