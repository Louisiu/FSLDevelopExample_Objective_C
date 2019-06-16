//
//  FSLMomentViewController.m
//  WeChat
//
//  Created by Fingal Liu on 2017/12/20.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import "FSLMomentViewController.h"
#import "FSLMomentHeaderView.h"
#import "FSLMomentFooterView.h"
#import "FSLMomentCommentCell.h"
#import "FSLMomentAttitudesCell.h"
#import "FSLMomentProfileView.h"
#import "FSLMomentOperationMoreView.h"
#import "LCActionSheet.h"
#import "FSLEmoticonManager.h"
#import "FSLMomentHelper.h"
#import "FSLMomentCommentToolView.h"
@interface FSLMomentViewController ()
/// viewModel
@property (nonatomic, readonly, strong) FSLMomentViewModel *viewModel;
/// tableHeaderView
@property (nonatomic, readwrite, weak) FSLMomentProfileView *tableHeaderView;
/// commentToolView
@property (nonatomic, readwrite, weak) FSLMomentCommentToolView *commentToolView;
/// 选中的索引 selectedIndexPath
@property (nonatomic, readwrite, strong) NSIndexPath * selectedIndexPath;
/// 记录键盘高度
@property (nonatomic, readwrite, assign) CGFloat keyboardHeight;
@end

@implementation FSLMomentViewController
@dynamic viewModel;

- (void)dealloc{
    FSLDealloc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化子控件
    [self _setupSubViews];
    
    /// 初始化导航栏Item
    [self _setupNavigationItem];
}

#pragma mark - Override
- (UIEdgeInsets)contentInset{
    return UIEdgeInsetsMake(FSL_IS_IPHONE_X?-40:-64, 0, 0, 0);
}

- (void)bindViewModel{
    [super bindViewModel];
    /// ... 事件处理...
    @weakify(self);
    /// 动态更新tableHeaderView的高度. PS:单纯的设置其高度无效的
    [[[RACObserve(self.viewModel.profileViewModel, unread)
      distinctUntilChanged]
     deliverOnMainThread]
     subscribeNext:^(NSNumber * unread) {
         @strongify(self);
         self.tableHeaderView.height = self.viewModel.profileViewModel.height;
         [self.tableView beginUpdates];  // 过度动画
         self.tableView.tableHeaderView = self.tableHeaderView;
         [self.tableView endUpdates];
     }];
    
    
    
    /// 全文/收起
    [[self.viewModel.reloadSectionSubject deliverOnMainThread] subscribeNext:^(NSNumber * section) {
        @strongify(self);
        /// 局部刷新 (内部已更新子控件的尺寸，这里只做刷新)
        /// 这个刷新会有个奇怪的动画
        /// [self.tableView reloadSection:section.integerValue withRowAnimation:UITableViewRowAnimationNone];
        /// Fingal Liu Fixed： 这里必须要加这句话！！！否则有个奇怪的动画！！！！
        [UIView performWithoutAnimation:^{
            [self.tableView reloadSection:section.integerValue withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];
    
    /// 评论
    [[self.viewModel.commentSubject deliverOnMainThread] subscribeNext:^(NSNumber * section) {
        @strongify(self);
        /// 记录选中的Section 这里设置Row为-1 以此来做判断
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:-1 inSection:section.integerValue];
        /// 显示评论
        [self _commentOrReplyWithItemViewModel:self.viewModel.dataSource[section.integerValue] indexPath:indexPath];
    }];
    
    /// 点击手机号码
    [[self.viewModel.phoneSubject deliverOnMainThread] subscribeNext:^(NSString * phoneNum) {

        LCActionSheet *sheet = [LCActionSheet sheetWithTitle:[NSString stringWithFormat:@"%@可能是一个电话号码，你可以",phoneNum] cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) return ;
        } otherButtonTitles:@"呼叫",@"复制号码",@"添加到手机通讯录", nil];
        [sheet show];
        
    }];
    
    /// 监听键盘 高度
    /// 监听按钮
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] takeUntil:self.rac_willDeallocSignal ]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * notification) {
         @strongify(self);
         @weakify(self);
         [self fsl_convertNotification:notification completion:^(CGFloat duration, UIViewAnimationOptions options, CGFloat keyboardH) {
             @strongify(self);
             if (keyboardH <= 0) {
                 keyboardH = -1 * self.commentToolView.height;
             }
             self.keyboardHeight = keyboardH;
             /// 全局记录keyboardH
             AppDelegate.sharedDelegate.showKeyboard = (keyboardH > 0);
             // bottomToolBar距离底部的高
             [self.commentToolView mas_updateConstraints:^(MASConstraintMaker *make) {
                 make.bottom.equalTo(self.view).with.offset(-1 *keyboardH);
             }];
             // 执行动画
             [UIView animateWithDuration:duration delay:0.0f options:options animations:^{
                 // 如果是Masonry或者autoLayout UITextField或者UITextView 布局 必须layoutSubviews，否则文字会跳动
                 [self.view layoutSubviews];
                 
                 /// 滚动表格
                 [self _scrollTheTableViewForComment];
             } completion:nil];
         }];
     }];
    
    
    //// 监听commentToolView的高度变化
    [[RACObserve(self.commentToolView, toHeight) distinctUntilChanged] subscribeNext:^(NSNumber * toHeight) {
        @strongify(self);
        if (toHeight.floatValue < FSLMomentCommentToolViewMinHeight) return ;
        /// 更新CommentView的高度
        [self.commentToolView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(toHeight);
        }];
        [UIView animateWithDuration:.25f animations:^{
            // 适当时候更新布局
            [self.view layoutSubviews];
            /// 滚动表格
            [self _scrollTheTableViewForComment];
        }];
    }];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath{
    return [FSLMomentContentCell cellWithTableView:tableView];
}

- (void)configureCell:(FSLMomentContentCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object{
    FSLMomentItemViewModel *itemViewModel =  self.viewModel.dataSource[indexPath.section];
    id model = itemViewModel.dataSource[indexPath.row];
    [cell bindViewModel:model];
}

#pragma mark - 初始化子控件
- (void)_setupSubViews{
    /// 配置tableView
    self.tableView.backgroundColor = [UIColor whiteColor];
    /// 固定高度-这样写比使用代理性能好，且使用代理会获取每次刷新数据会调用两次代理 ，苹果的bug
    self.tableView.sectionFooterHeight =  FSLMomentFooterViewHeight;
    
    /// 个人信息view
    FSLMomentProfileView *tableHeaderView = [[FSLMomentProfileView alloc] init];
    [tableHeaderView bindViewModel:self.viewModel.profileViewModel];
    self.tableView.tableHeaderView = tableHeaderView;
    self.tableView.tableHeaderView.height = self.viewModel.profileViewModel.height;
    self.tableHeaderView = tableHeaderView;

    /// 这里设置下拉黑色的背景图
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:FSL_SCREEN_BOUNDS];
    backgroundView.size = FSL_SCREEN_BOUNDS.size;
    backgroundView.image = FSLImageNamed(@"wx_around-friends_bg_320x568");
    backgroundView.top = -backgroundView.height;
    [self.tableView addSubview:backgroundView];
    
    
    /// 添加评论View
    FSLMomentCommentToolView *commentToolView = [[FSLMomentCommentToolView alloc] init];
    self.commentToolView = commentToolView;
    [self.view addSubview:commentToolView];
    [commentToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(60);
        make.bottom.equalTo(self.view).with.offset(60);
    }];
}

#pragma mark - 初始化道导航栏
- (void)_setupNavigationItem{
    @weakify(self);
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fsl_systemItemWithTitle:nil titleColor:nil imageName:@"barbuttonicon_Camera_30x30" target:nil selector:nil textType:NO];
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        LCActionSheet *sheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) return ;
            ///
        } otherButtonTitles:@"拍摄",@"从手机相册选择", nil];
        [sheet show];
        return [RACSignal empty];
    }];
}


/// PS:这里复写了 FSLTableViewController 里面的UITableViewDelegate和UITableViewDataSource的方法，所以大家不需要过多关注 FSLTableViewController的里面的UITableViewDataSource方法
#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FSLMomentItemViewModel *itemViewModel =  self.viewModel.dataSource[section];
    return itemViewModel.dataSource.count;
}

// custom view for header. will be adjusted to default or specified header height
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    FSLMomentHeaderView *headerView = [FSLMomentHeaderView headerViewWithTableView:tableView];
    /// 传递section 后期需要用到
    headerView.section = section;
    [headerView bindViewModel:self.viewModel.dataSource[section]];
    return headerView;
}
// custom view for footer. will be adjusted to default or specified footer height
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [FSLMomentFooterView footerViewWithTableView:tableView];
}

/// 点击Cell的事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    /// 先取出该section的说说
    FSLMomentItemViewModel *itemViweModel = self.viewModel.dataSource[section];
    /// 然后取出该 row 的评论Or点赞
    FSLMomentContentItemViewModel *contentItemViewModel = itemViweModel.dataSource[row];
    /// 去掉点赞
    if ([contentItemViewModel isKindOfClass:FSLMomentAttitudesItemViewModel.class]) {
        [self.commentToolView FSL_resignFirstResponder];
        return;
    }

    /// 判断是否是自己的评论  或者 回复
    FSLMomentCommentItemViewModel *commentItemViewModel = (FSLMomentCommentItemViewModel *)contentItemViewModel;
    if ([commentItemViewModel.comment.fromUser.idstr isEqualToString: self.viewModel.services.client.currentUser.idstr]) {
        /// 关掉键盘
        [self.commentToolView  FSL_resignFirstResponder];
        
        /// 自己评论的活回复他人
        @weakify(self);
        LCActionSheet *sheet = [LCActionSheet sheetWithTitle:nil cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) return ;
            @strongify(self);
            /// 删除数据源
            [self.viewModel.delCommentCommand execute:indexPath];
    
        } otherButtonTitles:@"删除", nil];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
        sheet.destructiveButtonIndexSet = indexSet;
        [sheet show];
        return;
    }
    
    /// 键盘已经显示 你就先关掉键盘
    if (FSLSharedAppDelegate.isShowKeyboard) {
        [self.commentToolView FSL_resignFirstResponder];
        return;
    }
    /// 评论
    [self _commentOrReplyWithItemViewModel:contentItemViewModel indexPath:indexPath];
}


// custom view for cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    // fetch object 报错 why???
//    id object  = [self.viewModel.dataSource[indexPath.section] dataSource][indexPath.row];
    FSLMomentItemViewModel *itemViewModel = self.viewModel.dataSource[indexPath.section];
    id object = itemViewModel.dataSource[indexPath.row];    
    /// bind model
    [self configureCell:cell atIndexPath:indexPath withObject:(id)object];
    return cell;
}

/// 设置高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    FSLMomentItemViewModel *itemViewModel = self.viewModel.dataSource[section];
    /// 这里每次刷新都会走两次！！！ Why？？？
    return itemViewModel.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSLMomentItemViewModel *itemViewModel =  self.viewModel.dataSource[indexPath.section];
    /// 这里用 id 去指向（但是一定要确保取出来的模型有 `cellHeight` 属性 ，否则crash）
    id model = itemViewModel.dataSource[indexPath.row];
    return [model cellHeight];
}

/// 监听滚动到顶部
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    /// 这里下拉刷新
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    /// 处理popView
    [FSLMomentHelper hideAllPopViewWithAnimated:NO];
}

#pragma mark - 辅助方法
- (void)_commentOrReplyWithItemViewModel:(id)itemViewModel indexPath:(NSIndexPath *)indexPath{
    /// 传递数据 (生成 replyItemViewModel)
    FSLMomentReplyItemViewModel *viewModel = [[FSLMomentReplyItemViewModel alloc] initWithItemViewModel:itemViewModel];
    viewModel.section = indexPath.section;
    viewModel.commentCommand = self.viewModel.commentCommand;
    self.selectedIndexPath = indexPath; /// 记录indexPath
    [self.commentToolView bindViewModel:viewModel];
    /// 键盘弹起
    [self.commentToolView  FSL_becomeFirstResponder];
}

/// 评论的时候 滚动tableView
- (void)_scrollTheTableViewForComment{
    CGRect rect = CGRectZero;
    CGRect rect1 = CGRectZero;
    if (self.selectedIndexPath.row == -1) {
        /// 获取整个尾部section对应的尺寸 获取的rect是相当于tableView的尺寸
        rect = [self.tableView rectForFooterInSection:self.selectedIndexPath.section];
        /// 将尺寸转化到window的坐标系 （关键点）
        rect1 = [self.tableView convertRect:rect toViewOrWindow:nil];
    }else{
        /// 回复
        /// 获取整个尾部section对应的尺寸 获取的rect是相当于tableView的尺寸
        rect = [self.tableView rectForRowAtIndexPath:self.selectedIndexPath];
        /// 将尺寸转化到window的坐标系 （关键点）
        rect1 = [self.tableView convertRect:rect toViewOrWindow:nil];
    }
    
    if (self.keyboardHeight > 0) { /// 键盘抬起 才允许滚动
        /// 这个就是你需要滚动差值
        CGFloat delta = self.commentToolView.top - rect1.origin.y - rect1.size.height;
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-delta) animated:NO];
    }else{
        /// #Bug
        /// 如果处于最后一个，需要滚动到底部
        if(self.selectedIndexPath.section == self.viewModel.dataSource.count-1){
            /// 去掉抖动
            [UIView performWithoutAnimation:^{
                [self.tableView scrollToBottomAnimated:NO];
            }];
        }
    }
}


@end
