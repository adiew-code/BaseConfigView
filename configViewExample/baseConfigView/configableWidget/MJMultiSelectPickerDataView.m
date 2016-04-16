//
//  MJMultiSelectPickerDataView.m
//  MJNSFA
//
//  Created by yang on 16/4/10.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJMultiSelectPickerDataView.h"

@implementation MJMultiSelectPickerDataView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath row] == 0)
    {
        [self touch];
        [self updateButtonTitle];
//        [self valueDidChanged];
        return;
    }
    
    NSObject <I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:[indexPath row] - 1];
    if ([self.selectItemArray containsObject:dataItem]) {
        [self.selectItemArray removeObject:dataItem];
    }else {
        [self.selectItemArray addObject:dataItem];
    }
    
    [self updateButtonTitle];
    
    [self reloadData];
    
    [self valueDidChanged];
}

- (BOOL)isItemSelected:(NSObject<I_W_OptionDataItem> *)item
{
    return [self.selectItemArray containsObject:item];
}

- (NSObject <I_W_OptionDataItem> *)getItemByName:(NSString *)name;
{
    for (NSObject <I_W_OptionDataItem> *item in self.dataSourceArray) {
        if ([[item getDataItemName] isEqualToString:name]) {
            return item;
        }
    }
    
    return nil;
}

- (void)setupSelectionByNameArray:(NSArray *)nameArray
{
    NSMutableArray *itemArray = [NSMutableArray array];
    
    for (NSString *name in nameArray) {
        NSObject <I_W_OptionDataItem> *item = [self getItemByName:name];
        if (item) {
            [itemArray addObject:item];
        }
    }
    
    if ([itemArray count] > 0) {
        [self setSelectItemArray:itemArray];
    }
    
}

- (NSString *)getSelectedContentString{
    NSMutableArray *nameArray = [NSMutableArray array];
    
    for (NSObject <I_W_OptionDataItem> *item in self.selectItemArray) {
        [nameArray addObject:[item getDataItemName]];
    }
    
    if ([nameArray count] > 0) {
        return [nameArray componentsJoinedByString:@","];
    }
    
    return self.configParam[kWidgetParam_PlaceHolder];

}

-(id)value
{
    return self.selectItemArray;
}


@end
