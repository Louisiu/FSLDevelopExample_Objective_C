//
//  FSLLanguageViewModel.h
//  WeChat
//
//  Created by Fingal Liu on 2017/10/13.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import "FSLTableViewModel.h"
#import "FSLLanguageItemViewModel.h"
@interface FSLLanguageViewModel : FSLTableViewModel
/// closeCommand
@property (nonatomic, readonly, strong) RACCommand *closeCommand;
/// 完成命令
@property (nonatomic, readonly, strong) RACCommand *completeCommand;
/// 完成按钮有效性
@property (nonatomic, readonly, strong) RACSignal *validCompleteSignal;
/// 选中的indexPath （一进来滚动到指定的界面）
@property (nonatomic, readonly, strong) NSIndexPath *indexPath;

@end
