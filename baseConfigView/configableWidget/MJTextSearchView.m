//
//  MJTextSearchView.m
//  textfiledSearchView
//
//  Created by zhiqing on 16/3/31.
//  Copyright © 2016年 asdfghj. All rights reserved.
//

#import "MJTextSearchView.h"
#import "PureLayout.h"

#define k_Font [UIFont systemFontOfSize:13]
#define k_tableRowHeight 44
#define kTopInset          (8)
#define kTraingInset       (2)

typedef NS_ENUM(NSInteger, MJTextSearchViewTag)  {
    MJFirstTextfieldTag = 1001,
    MJBackgroundViewTag = 1002,
    MJSecondTextfieldTag = 1003,
    MJDropTableViewTag = 1004,
};

@interface MJTextSearchView ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITextField * _firstTextfield;
    UITextField * _secondTextfield;
    UILabel * _label;
    UITableView * _dropTableView;
    UIView * _backgroundView ;
    CGRect _sourceRect;
    NSLayoutConstraint *_widthConstraintLable;
    // 键盘的位置
    CGRect _keyboardRect;
}
@end


@implementation MJTextSearchView

-(BOOL)setupSubViews{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    UIEdgeInsets inset = UIEdgeInsetsMake(2,kTopInset, 2, kTraingInset);
    _firstTextfield = [[UITextField alloc]init];
    _firstTextfield.tag = MJFirstTextfieldTag;
    _firstTextfield.textAlignment = NSTextAlignmentRight;
    _firstTextfield.layer.cornerRadius = 15;
    _firstTextfield.delegate = self;
    _label = [[UILabel alloc]init];
    _label.textAlignment = NSTextAlignmentLeft;
    _label.text = self.configParam[kWidgetParam_Lable];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = k_Font;
    _firstTextfield.enabled = [self.configParam[kWidgetParam_Enable] boolValue];
    _firstTextfield.text = self.configParam[kWidgetParam_Text];
    _firstTextfield.placeholder = self.configParam[kWidgetParam_PlaceHolder];
    _firstTextfield.keyboardType = [self.configParam[kWidgetParam_KeyboardType] integerValue];
    _firstTextfield.layer.borderWidth = 0.8;
    _firstTextfield.layer.borderColor = [UIColor grayColor].CGColor;
    _firstTextfield.layer.cornerRadius = 4;
    _firstTextfield.font = k_Font;
    NSString *text = self.configParam[kWidgetParam_Lable];
    if ([text isKindOfClass:[NSString class]] && text.length)
    {
        NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:text attributes:nil];
        
        if ([self.configParam[kWidgetParam_Required] boolValue])
        {
            [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
        }
        
        _label.attributedText = attribute;
    }

    [self addSubview:_label];
    [self addSubview:_firstTextfield];
    
    [_label autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeTrailing];
    [_label setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];
    if (width)
    {
        _widthConstraintLable = [_label autoSetDimension:ALDimensionWidth toSize:width];
    }

    [_firstTextfield autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeLeading];
    [_firstTextfield autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_label withOffset:[self.configParam[kWidgetParam_Horizontaloffset] integerValue]+4];

    return YES;
}

-(id)value
{
    return  _firstTextfield.text ;
   
}

-(void)setConfigParam:(NSDictionary *)configParam{
    
    if (configParam[kWidgetParam_Text])
         _firstTextfield.text = configParam[kWidgetParam_Text];
    
    
    if (configParam[kWidgetParam_Enable])
        _firstTextfield.enabled = [configParam[kWidgetParam_Enable] boolValue];
    
    if (configParam[kWidgetParam_PlaceHolder])
        _firstTextfield.placeholder = configParam[kWidgetParam_PlaceHolder];
    
    if (configParam[kWidgetParam_KeyboardType])
        _firstTextfield.placeholder = configParam[kWidgetParam_KeyboardType];
   
    
    [super setConfigParam:configParam];
}

#pragma -mark UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   // 初始化搜索视图
    if (textField.tag ==  MJFirstTextfieldTag) {
        [self setViewForTableView];
    }
    // 监听键盘改变的通知
    if (textField.tag == MJFirstTextfieldTag || textField.tag == MJSecondTextfieldTag) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTextfiledView:) name: UIKeyboardDidChangeFrameNotification object:nil];

    }
    
    // 当搜索的textfiled内容改变时模糊搜索
    if (textField.tag == MJSecondTextfieldTag) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UITextFieldTextDidChange) name: UITextFieldTextDidChangeNotification
 object:nil];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if (textField.tag == MJSecondTextfieldTag && [textField resignFirstResponder]) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    }
}


// 监听弹出模糊textfield的值改变的方法
-(void)UITextFieldTextDidChange{
    // 根据输入框的值发出通知去模糊搜索
    NSLog(@"%---@",_secondTextfield.text);
    
    __weak id <MJTextSearchViewDelegate> delegate = self.currentController;
    
    if ([delegate respondsToSelector:@selector(searchDataForMJTextSearchView:)]) {
       [delegate searchDataForMJTextSearchView:_secondTextfield.text];
    }
    [self changeTableFrameWithRect:_keyboardRect];
}
// 监听主要textfield的值改变的方法
-(void)MainUITextFieldTextDidChange{
    // 根据弹出输入框获取的值去监听主textfied

    [self valueDidChanged];
    
}
  // 改变之后 移除通知,并且记录此时键盘的位置改变位置
-(void)changeTextfiledView:(NSNotification *)noti{
  
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    NSValue *rectValue = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [rectValue CGRectValue];
    _keyboardRect = rect;
    [self changeTableFrameWithRect:rect];
    

}
#pragma -mark 根据键盘的高度改变tableview的显示方式  完成后移除通知
-(void)changeTableFrameWithRect:(CGRect)rect{
    if ( _dataSourceArray.count >= 6) {
        _dropTableView.frame = CGRectMake(_sourceRect.origin.x, _sourceRect.origin.y + _sourceRect.size.height, _sourceRect.size.width, 6.5 * k_tableRowHeight);
        
    }else{
        _dropTableView.frame = CGRectMake(_sourceRect.origin.x, _sourceRect.origin.y + _sourceRect.size.height, _sourceRect.size.width, _dataSourceArray.count * k_tableRowHeight);
    }
    // 如果键盘距离下拉框的距离不够,那么需要把页面向上推,够得话就显示,不改变位置
//    NSLog(@"%f",_dropTableView.frame.size.height);
        if (_sourceRect.origin.y + _dropTableView.frame.size.height > rect.origin.y)
        {
           [UIView animateWithDuration:0.25 animations:^{
               //
           } completion:^(BOOL finished) {
               if ([self.superview isKindOfClass:[UIScrollView class]])
               {
                   UIScrollView * scrollview = (UIScrollView *)self.superview;
                   scrollview.contentOffset = CGPointMake(0, _sourceRect.origin.y  +_dropTableView.height - rect.origin.y);
               }
               _secondTextfield.frame = CGRectMake(_sourceRect.origin.x,[UIScreen mainScreen].bounds.size.height - _dropTableView.frame.size.height - rect.origin.y - _sourceRect.size.height -10 , _sourceRect.size.width, _sourceRect.size.height);
               _dropTableView.frame = CGRectMake(_sourceRect.origin.x,[UIScreen mainScreen].bounds.size.height - _dropTableView.frame.size.height - rect.origin.y -10 , _sourceRect.size.width, _dropTableView.frame.size.height);
               
           }];
            

        }else{ // 当键盘消失的时候
            
            [UIView animateWithDuration:0.25 animations:^{
                //
            } completion:^(BOOL finished) {
                if ([self.superview isKindOfClass:[UIScrollView class]]) {
                    UIScrollView * scrollview = (UIScrollView *)self.superview;
                    scrollview.contentOffset = CGPointMake(0, 0);
                }
                _secondTextfield.frame = _sourceRect;
            }];
           
        }

}
-(void)setViewForTableView{
    _firstTextfield.enabled = NO;
    [_firstTextfield resignFirstResponder];
    UIWindow * window = [[UIApplication sharedApplication].windows firstObject];
    window.frame = [UIScreen mainScreen].bounds;
    UIView * rootView = window.rootViewController.view;
    _sourceRect = [_firstTextfield convertRect:_firstTextfield.bounds toView:rootView];

    _backgroundView= [[UIView alloc]initWithFrame:rootView.bounds];
    _backgroundView.tag = MJBackgroundViewTag;
    _backgroundView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [_backgroundView addGestureRecognizer:tapRecognizer];
    _backgroundView.alpha = 0.5;
    _secondTextfield = [[UITextField alloc]initWithFrame:_sourceRect];
    _secondTextfield.textAlignment = NSTextAlignmentRight;
    _secondTextfield.delegate = self;
    _secondTextfield.layer.borderWidth = 0.8;
  
    _secondTextfield.layer.borderColor = [UIColor blackColor].CGColor;
 
    _secondTextfield.layer.cornerRadius = 4;

    _secondTextfield.tag = MJSecondTextfieldTag;
    [_secondTextfield becomeFirstResponder];
    
    _dropTableView = [[UITableView alloc]initWithFrame:CGRectMake(_sourceRect.origin.x, _sourceRect.origin.y + _sourceRect.size.height, _sourceRect.size.width, 0)];
    _dropTableView.delegate = self;
    _dropTableView.dataSource = self;
    _dropTableView.tag = MJDropTableViewTag;
    [rootView addSubview:_backgroundView];
    [rootView addSubview:_secondTextfield];
    [rootView addSubview:_dropTableView];
    [rootView bringSubviewToFront:_dropTableView];
}

#pragma -mark 当外界设置数据源的时候刷新tableview 
-(void)setDataSourceArray:(NSArray *)dataSourceArray{
    _dataSourceArray = dataSourceArray;
    
    [_dropTableView reloadData];

}

#pragma  -mark UITableViewDelegate,UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return k_tableRowHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _dataSourceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuserId = @"UITableViewCellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }
    cell.textLabel.text = _dataSourceArray[indexPath.row];
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    _secondTextfield.text = cell.textLabel.text;
    [self touch];
}
- (void)touch
{
    UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView* rootView= wc.rootViewController.view;
    for(UIView* view in rootView.subviews){
        if (view.tag == MJBackgroundViewTag || view.tag == MJSecondTextfieldTag || view.tag == MJDropTableViewTag) {
            [view removeFromSuperview];
        }
    }
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView * scrollView = (UIScrollView *)self.superview;
        scrollView.contentOffset = CGPointMake(0, 0);
    }
    self.hidden = NO;
    _firstTextfield.enabled = YES;
    [_firstTextfield resignFirstResponder];
    _firstTextfield.text = _secondTextfield.text;
    [self MainUITextFieldTextDidChange];
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    // 移除通知
}

@end
