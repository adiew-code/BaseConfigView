//
//  MJMJStoresDetailRowView.h
//  MJNSFA
//
//  Created by weida on 16/2/4.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJBaseWidgetView;

@interface MJBasePlistConfigRowView : UIView

-(instancetype)initWithFirstView:(NSDictionary*)firstConfig secondView:(NSDictionary*)secondConfig;

-(id)getValueByindex:(NSInteger)index;

-(MJBaseWidgetView*)getWidgetByIndex:(NSInteger)index;

-(BOOL)checkInputOfAllWidget;

@end
