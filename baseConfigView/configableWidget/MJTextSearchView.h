//
//  MJTextSearchView.h
//  textfiledSearchView
//
//  Created by zhiqing on 16/3/31.
//  Copyright © 2016年 asdfghj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJBaseWidgetView.h"

@protocol MJTextSearchViewDelegate <NSObject>

-(void)searchDataForMJTextSearchView:(NSString *)conditions;

@end

@interface MJTextSearchView : MJBaseWidgetView
//@property(nonatomic,weak) id <MJTextSearchViewDelegate> delegate;
@property(nonatomic,strong) NSArray *dataSourceArray;
@end
