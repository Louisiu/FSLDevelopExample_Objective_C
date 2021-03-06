//
//  FSLMomentReplyItemViewModel.h
//  WeChat
//
//  Created by Fingal Liu on 2018/1/24.
//  Copyright © 2018年 Fingal Liu. All rights reserved.
//  点击评论 或者点击 评论Cell ,通过 Router 模式生成一个 FSLMomentReplyItemViewModel 用于 commentToolView的绑定

#import <Foundation/Foundation.h>

@interface FSLMomentReplyItemViewModel : NSObject

/// 传进来的itemViewModel
@property (nonatomic, readonly, strong) id itemViewModel;
/// idStr(评论的id)
@property (nonatomic, readonly, copy) NSString *idstr;
/// momentIdstr(该评论的所处的说说的id)
@property (nonatomic, readonly, copy) NSString *momentIdstr;
/// 回复:xxx （目标）
@property (nonatomic, readonly, strong) FSLUser *toUser;
/** 是否是 回复:xxx （目标） */
@property (nonatomic, readonly, assign , getter = isReply) BOOL reply;
/// 记录Section
@property (nonatomic, readwrite, assign) NSInteger section;
/// 发送评论内容
@property (nonatomic, readwrite, strong) RACCommand *commentCommand;

/// text (输入款输入的内容)
@property (nonatomic, readwrite, copy) NSString *text;


//// 初始化 （Router）
/// - itemViewModel : `FSLMomentItemViewModel` 或者 `FSLMomentCommentItemViewModel`
- (instancetype)initWithItemViewModel:(id)itemViewModel;

@end
