//
//  MJPickerDataView.m
//  MJNSFA
//
//  Created by weida on 16/1/28.
//  Copyright © 2016年 meadjohnson. All rights reserved.
//

#import "MJPickerDataView.h"
#import "MJSingelDropListCell.h"
#import "MJSingleDropViewModel.h"
#import "NSString+Util.h"

@interface MJPickerDataView ()
{
    UILabel *_textLable;
    UITableView * _dropListTableView;
    UIView * _backgroundView;
    NSLayoutConstraint *_widthConstraintLable;
    CGFloat tableRowHeight;
    CGRect sourceRect;
}
@property (nonatomic, strong) NSObject<I_W_OptionDataItem> *selectedItem;  //for single select

@end

@implementation MJPickerDataView

-(instancetype)initWithConfigParam:(NSDictionary *)configParam
{
    self = [super initWithConfigParam:configParam];
   
    if (!self.dataSourceArray.count)
    {
        NSArray *data_source = configParam[kWidgetParam_DataSource];
        if (data_source.count)
        {
            NSMutableArray * array = [[NSMutableArray alloc]init];
            for (int i = 0; i < data_source.count; i++) {
                MJSingleDropViewModel * model = [[MJSingleDropViewModel alloc]init];
                model.index = (@(i)).stringValue;
                model.dropCont = data_source[i];
                [array addObject:model];
            }
            self.dataSourceArray = array;
        }
    }
    
    self.selectItemArray = [NSMutableArray array];

    return self;
}


-(BOOL)setupSubViews
{
    if ([super setupSubViews])
    {//防止本方法被调用多次
        return YES;
    }
    
    _textLable = [UILabel newAutoLayoutView];
    _textLable.font = kFont;
    NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:[NSString stringNotNilWithValue: self.configParam[kWidgetParam_Lable]] attributes:nil];
    
    if ([self.configParam[kWidgetParam_Required] boolValue])
    {
        [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
    }
    
    _textLable.attributedText = attribute;
    [self addSubview:_textLable];
    UIEdgeInsets inset = UIEdgeInsetsMake(2, 8, 2, 2);
    [_textLable autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeTrailing];
    [_textLable setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    CGFloat width = [self.configParam[kWidgetParam_LableWidth] floatValue];//Lable 的宽度固定吗？
    if (width)
    {
        _widthConstraintLable =  [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    
    
    _button = [UIButton newAutoLayoutView];
    _button.titleLabel.font = _textLable.font;
    _button.enabled = [self.configParam[kWidgetParam_Enable] boolValue];
    _button.layer.borderWidth = 1;
    _button.layer.borderColor = (_button.enabled?kBtnNomalBkColor:kBtnDisableBkColor).CGColor;
    [_button setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0,0)];
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_button setTitle:self.configParam[kWidgetParam_PlaceHolder] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [_button setImage:[UIImage imageNamed:@"menu_xialan_arrow"] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.cornerRadius = 15;
    
    [self addSubview:_button];
    [_button autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeLeading];
    [_button autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_textLable withOffset:[self.configParam[kWidgetParam_Horizontaloffset] integerValue]];
    
    
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [_button setImageEdgeInsets:UIEdgeInsetsMake(0, _button.bounds.size.width - 46, 0, 0)];
    
    [self changeTableFrame];
}

-(void)setDataSourceArray:(NSArray *)dataSourceArray
{
    _dataSourceArray  = dataSourceArray;
    _selectedItem = nil;
    [self updateButtonTitle];

}

-(void)setSelectItemArray:(NSMutableArray *)selectItemArray{
    _selectItemArray = selectItemArray;
    [self updateButtonTitle];
    [_dropListTableView reloadData];
}

- (void)setSelectedOption:(NSObject <I_W_OptionDataItem>*)optionItem {
    _selectedItem = optionItem;
    
    [self updateButtonTitle];
}

- (void)setSelectedOptionByName:(NSString *)optionName {
    
    for (NSObject <I_W_OptionDataItem>* item in self.dataSourceArray) {
        if ([[item getDataItemName] isEqualToString:optionName]) {
            _selectedItem = item;
            break;
        }
    }
    [self updateButtonTitle];
}

-(void)btnClick:(UIButton *)sender
{
    [self valueWillChanged];
    
    tableRowHeight = _button.frame.size.height;
    // 弹出下拉单选框
    UIWindow * window = [[[UIApplication sharedApplication] windows] firstObject];
    window.frame = [UIScreen mainScreen].bounds;
    UIView * rootView = window.rootViewController.view;
    rootView.backgroundColor = [UIColor grayColor];
    sourceRect = [_button convertRect:_button.bounds toView:rootView];
    if (_dropListTableView == nil) {
        _dropListTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _dropListTableView.layer.cornerRadius = _button.layer.cornerRadius;
        _dropListTableView.bounces = NO;
        _dropListTableView.dataSource = self;
        _dropListTableView.delegate = self;
    }
    _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y, sourceRect.size.width, 0);
    _dropListTableView.tag = 9876;
    if (_backgroundView == nil)
    {
        _backgroundView = [[UIView alloc] initWithFrame:rootView.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setNumberOfTouchesRequired:1];
        [_backgroundView addGestureRecognizer:tapRecognizer];
    }
    _backgroundView.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        [rootView addSubview:_backgroundView];

        [rootView addSubview:_dropListTableView];
        
        [self changeTableFrame];
//        if ([self getCellCount] >= 6) {
//            _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y, sourceRect.size.width, 6 * tableRowHeight);
//
//        }else{
//             _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y, sourceRect.size.width, [self getCellCount] * tableRowHeight);
//        }
//        
//        if (_dropListTableView.frame.origin.y + _dropListTableView.frame.size.height > _dropListTableView.superview.frame.size.height) {
//            _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y - _dropListTableView.frame.size.height + _button.frame.size.height, sourceRect.size.width, 200);
//        }
         _backgroundView.alpha = 0.5;
    } completion:^(BOOL finished) {
        
        [rootView bringSubviewToFront:_dropListTableView];
    }];
    
    _backgroundView.tag=9875;
    [_dropListTableView reloadData];
}

- (NSInteger)getCellCount
{
    return self.dataSourceArray.count + 1;
}

-(void)changeTableFrame{
    
    if ([self getCellCount] >= 6) {
        _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y, sourceRect.size.width, 6.5 * tableRowHeight);
        
    }else{
        _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y, sourceRect.size.width, [self getCellCount] * tableRowHeight);
    }
    
    if (_dropListTableView.frame.origin.y + _dropListTableView.frame.size.height > _dropListTableView.superview.frame.size.height) {
        CGFloat height = 0;
        if ([self getCellCount] >=6) {
            height = 6.5 * tableRowHeight;
        }else{
            height = [self getCellCount] * tableRowHeight;
        }
        _dropListTableView.frame = CGRectMake(sourceRect.origin.x, sourceRect.origin.y - height + _button.frame.size.height, sourceRect.size.width, height);
    }

}

- (void)updateButtonTitle
{
    NSString *title = self.configParam[kWidgetParam_PlaceHolder];
    if ([self.dataSourceArray count] == 0) {
        
        if (_button.enabled)
        {
           title = @"暂无选项";
        }else
        {
             title = self.configParam[kWidgetParam_currentSelected];
        }
        
       
        _button.selected = NO;
    }else {
        title = [self getSelectedContentString];
        _button.selected = self.selectedItem?YES:NO;
    }
    [_button setTitle:title forState:UIControlStateNormal];
    [_button setTitle:title forState:UIControlStateDisabled];
}

- (NSString *)getSelectedContentString{
      NSString *result = nil;
    if(self.selectedItem){
        // -- getDataItemName  方法需要在 数据模型中去实现
        result = [self.selectedItem getDataItemName];
    }else{
        result = self.configParam[kWidgetParam_PlaceHolder];
    }
    return result;
}

- (void)touch
{
    UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView* rootView= wc.rootViewController.view;
    for(UIView* view in rootView.subviews){
        if(view.tag==9876){
            [UIView animateWithDuration:0.25 animations:^{
                //
                 view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 0);
               
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
            
        }
        if(view.tag==9875){
//            [self moveSourceTableDown];
            [UIView animateWithDuration:0.25 animations:^{
                //
                view.alpha = 0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
            
        }
    }
    
    self.hidden = NO;
}

- (BOOL)isItemSelected:(NSObject<I_W_OptionDataItem> *)item
{
    BOOL isSelected = NO;
    if (self.selectedItem == item) {
        isSelected = YES;
    }
    
    return isSelected;
}

#pragma mark  UITableViewDataSource,UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableRowHeight;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
   return [self getCellCount];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * reuserId = @"dropListViewId";
    MJSingelDropListCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    
    if (cell == nil) {
        cell = [[MJSingelDropListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }
    if (indexPath.row == 0) {
        MJSingleDropViewModel * model = [[MJSingleDropViewModel alloc]init];
        model.index = (@(0)).stringValue;
        model.dropCont = self.configParam[kWidgetParam_PlaceHolder];
        [cell setDataItem:model isSelected:NO];
        cell.markImageView.image = [UIImage imageNamed:@"menu_xialan_arrow"];
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [cell.markImageView setTransform:transform];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        // 需要添加方法 设置每行cell 的内容
        NSObject<I_W_OptionDataItem> *dataItem = [self.dataSourceArray objectAtIndex:[indexPath row] - 1];

        [cell setDataItem:dataItem isSelected:[self isItemSelected:dataItem]];
        cell.markImageView.image = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath row] == 0)
    {
        self.selectedItem = nil;
        [self touch];
        [self updateButtonTitle];
        
        [self valueDidChanged];
        return;
    }
    if (_selectedItem != [self.dataSourceArray objectAtIndex:[indexPath row] - 1])
    {
//        _isValueChange = YES; 待确定是否需要
        self.selectedItem = [self.dataSourceArray objectAtIndex:[indexPath row] - 1];
        //modify by jimmy lee, some problem may be occured.
        [self.selectItemArray addObject:  self.selectedItem ];
    }

    [self touch];
    [self updateButtonTitle];
    [_dropListTableView reloadData];
    
    [self valueDidChanged];
}
- (void)reloadData
{
    [_dropListTableView reloadData];
}

-(id)value
{
    return _selectedItem;
}

-(void)setConfigParam:(NSDictionary *)configParam
{
    [super setConfigParam:configParam];
    
    CGFloat width = [configParam[kWidgetParam_LableWidth] floatValue];//Lable 的宽度固定吗？
    if (width)
    {
        [_textLable removeConstraint:_widthConstraintLable];
        _widthConstraintLable =  [_textLable autoSetDimension:ALDimensionWidth toSize:width];
    }
    BOOL enable = [self.configParam[kWidgetParam_Enable] boolValue];
    
    [_button setTitle:[self getSelectedContentString] forState:UIControlStateNormal];
    _button.enabled = enable;
    _button.layer.borderColor = (enable?kBtnNomalBkColor:kBtnDisableBkColor).CGColor;
    
    NSMutableAttributedString* attribute =  [[NSMutableAttributedString alloc]initWithString:[NSString stringNotNilWithValue: self.configParam[kWidgetParam_Lable]] attributes:nil];
    
    if ([self.configParam[kWidgetParam_Required] boolValue])
    {
        [attribute insertAttributedString:[[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}] atIndex:0];
    }
    
    if (configParam[kWidgetParam_currentSelected])
    {
        for (NSObject <I_W_OptionDataItem>* model in self.dataSourceArray)
        {
            if ([self.configParam[kWidgetParam_currentSelected] isEqualToString:[model getDataItemName]]
                || [self.configParam[kWidgetParam_currentSelected] isEqualToString:[model getDataItemID]] )
            {
                _selectedItem = model;
                break;
            }else
            {
                _selectedItem = nil;
            }
        }
        [self updateButtonTitle];
    }
    
    if (configParam[kWidgetParam_DataSource])
    {
        NSArray *data_source = configParam[kWidgetParam_DataSource];
        if ([data_source isKindOfClass:[NSArray class]] && data_source.count)
        {
            NSMutableArray * array = [[NSMutableArray alloc]init];
            for (int i = 0; i < data_source.count; i++) {
                MJSingleDropViewModel * model = [[MJSingleDropViewModel alloc]init];
                model.index = (@(i)).stringValue;
                model.dropCont = data_source[i];
                [array addObject:model];
            }
            self.dataSourceArray = array;
        }else
        {
            self.dataSourceArray = nil;
        }

    }
    
   
    
    _textLable.attributedText = attribute;
   
}


@end
