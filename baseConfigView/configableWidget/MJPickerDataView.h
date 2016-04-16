//
//  MJPickerDataView.h
//  MJNSFA
//
//  Created by weida on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJBaseWidgetView.h"
#import "I_W_OptionDataItem.h"
@interface MJPickerDataView : MJBaseWidgetView <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSArray *dataSourceArray;          // 需要展示的列表项
@property(nonatomic,strong) NSMutableArray *selectItemArray;   // 已经选择的条目
@property (nonatomic, strong) UIButton *button;  


- (void)setSelectedOption:(NSObject <I_W_OptionDataItem>*)optionItem;

- (void)setSelectedOptionByName:(NSString *)optionName;

- (BOOL)isItemSelected:(NSObject<I_W_OptionDataItem> *)item;

- (void)touch;

- (void)updateButtonTitle;

- (void)reloadData;

- (NSString *)getSelectedContentString;

@end
