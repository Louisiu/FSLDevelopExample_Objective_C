//
//  FSLLoginBaseViewModel.m
//  WeChat
//
//  Created by senba on 2017/9/26.
//  Copyright © 2017年 CoderMikeHe. All rights reserved.
//

#import "FSLLoginBaseViewModel.h"

@implementation FSLLoginBaseViewModel
- (void)initialize{
    [super initialize];
    
    /// 隐藏导航栏的细线
    self.prefersNavigationBarBottomLineHidden = YES;
}
@end
