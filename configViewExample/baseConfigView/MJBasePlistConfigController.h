//
//  MJBasePlistConfigController.h
//  MJNSFA
//
//  Created by weida on 16/2/25.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//


#import "MJBaseWidgetView.h"
#import "MJBasePlistConfigView.h"



/**
 *  @brief 根据Plist文件自动设置界面
 */

@interface MJBasePlistConfigController : UIViewController<MJBasePlistConfigViewDelegate>

@property(nonatomic,strong,readonly)MJBasePlistConfigView *baseConfigView;

/**
 *  @brief 子类重写此方法，初始化自己数据
 */
-(void)initData;


/**
 *  @brief 子类可以重写此方法设置BaseConfigView在整个view中的布局
 *
 *  @return 上下左右间距
 */
-(UIEdgeInsets)baseConfigViewEdgeInsets;
@end
