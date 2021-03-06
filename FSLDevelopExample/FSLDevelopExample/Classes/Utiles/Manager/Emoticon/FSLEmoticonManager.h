//
//  FSLEmoticonManager.h
//  WeChat
//
//  Created by Fingal Liu on 2018/1/20.
//  Copyright © 2018年 Fingal Liu. All rights reserved.
//  表情管理器

#import <Foundation/Foundation.h>
#import "FSLEmoticonGroup.h"
@interface FSLEmoticonManager : NSObject
/// 表情图片的资源文件
+ (NSBundle *)emoticonBundle;
/// 表情正则表达式
+ (NSRegularExpression *)regexEmoticon;
/// 表情字典 
+ (NSDictionary *)emoticonDic;
/// 表情组
+ (NSArray<FSLEmoticonGroup *> *)emoticonGroups;
/// 朋友圈表情缓存
+ (YYMemoryCache *)imageCache;
/// 通过路径获取图片 (有缓存)
+ (UIImage *)imageWithPath:(NSString *)path;
@end
