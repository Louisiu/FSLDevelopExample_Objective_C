//
//  FSLMomentVideo.m
//  WeChat
//
//  Created by Fingal Liu on 2018/2/2.
//  Copyright © 2018年 Fingal Liu. All rights reserved.
//

#import "FSLMomentVideo.h"

@implementation FSLMomentVideo

- (void)setFileName:(NSString *)fileName{
    _fileName = [fileName copy];
    
    /// 这里设置封面和播放地址  因为这里都是本地的
    if (!FSLStringIsNotEmpty(fileName)) return;
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:fileName ofType:nil];
    self.playUrl = [NSURL fileURLWithPath:urlStr];
    
    /// 获取视频第一政
    self.coverImage = [UIImage fsl_thumbnailImageForVideo:self.playUrl atTime:1];
}

@end
