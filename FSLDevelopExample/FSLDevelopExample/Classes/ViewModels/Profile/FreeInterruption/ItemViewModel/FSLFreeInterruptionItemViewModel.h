//
//  FSLFreeInterruptionItemViewModel.h
//  WeChat
//
//  Created by Fingal Liu on 2017/12/11.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSLFreeInterruptionItemViewModel : NSObject
/// title
@property (nonatomic, readonly, copy) NSString *title;
/// idstr
@property (nonatomic, readonly, copy) NSString *idstr;
/// 是否选中
@property (nonatomic, readwrite, assign) BOOL selected;

- (instancetype)initItemViewModelWithIdstr:(NSString *)idstr title:(NSString *)title;
+ (instancetype)itemViewModelWithIdstr:(NSString *)idstr title:(NSString *)title;
@end
