//
//  FSLMomentOperationMoreView.m
//  FSLDevelopExample
//
//  Created by Fingal Liu on 2017/7/15.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import "FSLMomentOperationMoreView.h"
#import "FSLMomentOperationMoreItemView.h"
#import "FSLMomentItemViewModel.h"

/// Hide Notification
static NSString * const FSLMomentOperationMoreViewHideNotification = @"FSLMomentOperationMoreViewHideNotification";
static NSString * const FSLMomentOperationMoreViewHideUserInfoKey = @"FSLMomentOperationMoreViewHideUserInfoKey";


@interface FSLMomentOperationMoreView ()
/// viewModel
@property (nonatomic, readwrite, strong) FSLMomentItemViewModel *viewModel;
/// 点赞
@property (nonatomic, readwrite, weak) FSLMomentOperationMoreItemView *attitudesBtn;
/// 评论
@property (nonatomic, readwrite, weak) FSLMomentOperationMoreItemView *commentBtn;
/// 分割线
@property (nonatomic, readwrite, weak) UIImageView *divider;
/// 是否已显示
@property (nonatomic, readwrite, assign) BOOL isShow;

@end

@implementation FSLMomentOperationMoreView

+ (instancetype)operationMoreView
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /// 设置能交互
        self.userInteractionEnabled = YES;
        self.image = [UIImage fsl_resizableImage:@"wx_albumOperateMoreViewBkg_40x39"];
        /// 当宽度为0的时候 子控件也消失
        self.clipsToBounds = YES;
        /// 高亮状态下的背景色
        /// 评论
        UIImage * cBackgroundImage = [UIImage fsl_resizableImage:@"wx_albumCommentBackgroundHL_15x39"];
        /// 赞
        UIImage * aBackgroundImage = [UIImage fsl_resizableImage:@"wx_albumLikeBackgroundHL_15x39"];
        /// 设置点赞按钮
        FSLMomentOperationMoreItemView *attitudesBtn = [FSLMomentOperationMoreItemView buttonWithType:UIButtonTypeCustom];
        [attitudesBtn setTitle:@"赞" forState:UIControlStateNormal];
        [attitudesBtn setImage:FSLImageNamed(@"wx_albumLike_20x20") forState:UIControlStateNormal];
        [attitudesBtn setImage:FSLImageNamed(@"wx_albumLikeHL_20x20") forState:UIControlStateHighlighted];
        [attitudesBtn setBackgroundImage:aBackgroundImage forState:UIControlStateHighlighted];
        /// 开启点击动画
        attitudesBtn.allowAnimationWhenClick = YES;
        self.attitudesBtn = attitudesBtn;
        [self addSubview:attitudesBtn];
        
        /// 设置分割线
        UIImageView *divider = [[UIImageView alloc] initWithImage:FSLImageNamed(@"wx_albumCommentLine_0x24")];
        self.divider = divider;
        [self addSubview:divider];
        
        /// 设置评论按钮
        FSLMomentOperationMoreItemView *commentBtn = [FSLMomentOperationMoreItemView buttonWithType:UIButtonTypeCustom];
        [commentBtn setTitle:@"评论" forState:UIControlStateNormal];
        [commentBtn setImage:FSLImageNamed(@"wx_albumCommentSingleA_20x20") forState:UIControlStateNormal];
        [commentBtn setImage:FSLImageNamed(@"wx_albumCommentSingleAHL_20x20") forState:UIControlStateHighlighted];
        [commentBtn setBackgroundImage:cBackgroundImage forState:UIControlStateHighlighted];
        self.commentBtn = commentBtn;
        [self addSubview:commentBtn];
        
        /// 事件处理
        @weakify(self);
        /// 点赞点击事件
        [[attitudesBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(UIButton *sender) {
             @strongify(self);
             !self.attitudesClickedCallback?:self.attitudesClickedCallback(self);
             [self hideAnimated:YES afterDelay:FSLMommentAnimatedDuration];
             
         }];
        /// 评论点击事件
        [[commentBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(UIButton *sender) {
             @strongify(self);
             /// 这里实现判断 键盘是否已经抬起
             if (FSLSharedAppDelegate.isShowKeyboard) {
                 [FSLSharedAppDelegate.window endEditing:YES]; /// 关掉键盘
             }else{
                 !self.commentClickedCallback?:self.commentClickedCallback(self);
                 [self hideAnimated:YES afterDelay:0.1];
             }
         }];
        
        
        /// 添加通知
        [[FSLNotificationCenter rac_addObserverForName:FSLMomentOperationMoreViewHideNotification object:nil] subscribeNext:^(NSNotification * note) {
            BOOL animated = [note.userInfo[FSLMomentOperationMoreViewHideUserInfoKey] boolValue];
            [self hideWithAnimated:animated];
        }];
    }
    return self;
}
#pragma mark - Show Or Hide

- (void)showWithAnimated:(BOOL)animated
{
    if (self.isShow) return;
    
    /// 隐藏之前显示的所有的MoreView
    [[self class] hideAllOperationMoreViewWithAnimated:YES];
    
    /// 置为Yes
    self.isShow = YES;
    
    if (!animated) {
        self.width = FSLMomentOperationMoreViewWidth;
        self.left = self.left-self.width;
        return;
    }
    
    /// 动画
    [UIView animateWithDuration:FSLMommentAnimatedDuration delay:0 usingSpringWithDamping:.7f initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.width = FSLMomentOperationMoreViewWidth;
        self.left = self.left-self.width;
        /// 强制布局
      
    } completion:^(BOOL finished) {
    }];
}

- (void)hideWithAnimated:(BOOL)animated
{
    [self hideAnimated:animated afterDelay:0];
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    if (!self.isShow) return;
    
     self.isShow = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (!animated) {
            // 无动画
            self.left = self.left + self.width;
            self.width = 0;
            self.isShow = NO;
            return ;
        }

        /// 动画
        [UIView animateWithDuration:FSLMommentAnimatedDuration delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.left = self.left + self.width;
            self.width = 0;
            /// 强制布局
            
        } completion:^(BOOL finished) {
        }];
        
    });

}

/// 隐藏所有操作Menu
+ (void)hideAllOperationMoreViewWithAnimated:(BOOL)animated;{
    /// 发布通知
    [FSLNotificationCenter postNotificationName:FSLMomentOperationMoreViewHideNotification object:nil userInfo:@{FSLMomentOperationMoreViewHideUserInfoKey:@(animated)}];
}


#pragma mark - BinderData
- (void)bindViewModel:(FSLMomentItemViewModel *)viewModel{
    self.viewModel = viewModel;
    /// 直接设置 normal 状态下文字即可
    [self.attitudesBtn setTitle:viewModel.moment.attitudesStatus==0?@"赞":@"取消" forState:UIControlStateNormal];
}


- (void)setFrame:(CGRect)frame{
    /// 固定高度
    frame.size.height = FSLMomentOperationMoreViewHeight;
    [super setFrame:frame];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    /// 布局赞
    CGFloat attitudesBtnW = (self.width - self.divider.width)*.5f;
    CGFloat attitudesBtnH = self.height;
    self.attitudesBtn.size = CGSizeMake(attitudesBtnW, attitudesBtnH);
    
    
    /// 布局分割线
    self.divider.left = CGRectGetMaxX(self.attitudesBtn.frame);
    self.divider.centerY = self.height*.5f;
    
    
    /// 布局评论
    CGFloat commentBtnX = CGRectGetMaxX(self.divider.frame);
    CGFloat commentBtnW = attitudesBtnW;
    CGFloat commentBtnH = attitudesBtnH;
    self.commentBtn.frame = CGRectMake(commentBtnX, 0, commentBtnW, commentBtnH);
    
}
@end
