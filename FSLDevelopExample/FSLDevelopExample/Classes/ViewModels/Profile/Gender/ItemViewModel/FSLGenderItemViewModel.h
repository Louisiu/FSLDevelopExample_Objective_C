//
//  FSLGenderItemViewModel.h
//  WeChat
//
//  Created by Fingal Liu on 2017/10/15.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSLGenderItemViewModel : NSObject
/// title
@property (nonatomic, readonly, copy) NSString *title;
/// idstr
@property (nonatomic, readonly, copy) NSString *idstr;
/// 是否选中
@property (nonatomic, readwrite, assign) BOOL selected;

/// 初始化
- (instancetype)initItemViewModelWithIdstr:(NSString *)idstr title:(NSString *)title;
+ (instancetype)itemViewModelWithIdstr:(NSString *)idstr title:(NSString *)title;
@end
