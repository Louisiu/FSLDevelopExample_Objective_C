//
//  FSLSearchFriendsViewModel.m
//  WeChat
//
//  Created by Fingal Liu on 2017/9/24.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import "FSLSearchFriendsViewModel.h"

@interface FSLSearchFriendsViewModel ()
/// searchCommand
@property (nonatomic, readwrite, strong) RACCommand *searchCommand;

@end

@implementation FSLSearchFriendsViewModel

- (void)initialize{
    [super initialize];
    @weakify(self);
    
    /// 多组
    self.shouldMultiSections = YES;
    self.interactivePopDisabled = YES;
    
    /// 监听searchText的变化
    [[RACObserve(self, searchText) distinctUntilChanged] subscribeNext:^(NSString * searchText) {
        @strongify(self);
        ///
        if (FSLStringIsNotEmpty(searchText)) {
            /// 添加一个数据
            self.dataSource = @[@[self]];
        }else{
            self.dataSource = @[];
        }
    }];
    
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath * indexPath) {
        @strongify(self);
        id itemViewModel = self.dataSource[indexPath.section][indexPath.row];
        if ([itemViewModel isKindOfClass:self.class]) {
            /// 搜索
            [self.searchCommand execute:self.searchText];
        }else{
            /// 其他
        }
        return [RACSignal empty];
    }];
    
    /// 搜索cmd
    self.searchCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString * searchText) {
        @strongify(self);
        @weakify(self);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            NSLog(@"+++++++_____++++++");
            return [RACDisposable disposableWithBlock:^{
            }];
        }];
    }];
    
    
    ///
    
}

@end
