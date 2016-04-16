//
//  MJSingleDropViewModel.h
//  MJNSFA
//
//  Created by admin on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_OptionDataItem.h"
@interface MJSingleDropViewModel : NSObject<I_W_OptionDataItem>
@property(nonatomic,copy) NSString *index;
@property(nonatomic,copy) NSString *dropCont;
@end
