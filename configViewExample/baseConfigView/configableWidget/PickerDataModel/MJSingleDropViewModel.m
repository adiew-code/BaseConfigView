//
//  MJSingleDropViewModel.m
//  MJNSFA
//
//  Created by admin on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJSingleDropViewModel.h"

@implementation MJSingleDropViewModel
-(NSString *)getDataItemID{

    return self.index;
    

}
-(NSString *)getDataItemName{

    return self.dropCont;
}
@end
