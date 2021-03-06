//
//  FSLEmoticonGroup.m
//  WeChat
//
//  Created by Fingal Liu on 2018/1/20.
//  Copyright © 2018年 Fingal Liu. All rights reserved.
//

#import "FSLEmoticonGroup.h"

@implementation FSLEmoticonGroup
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"groupID" : @"id",
             @"nameCN" : @"group_name_cn",
             @"nameEN" : @"group_name_en",
             @"nameTW" : @"group_name_tw",
             @"displayOnly" : @"display_only",
             @"groupType" : @"group_type"};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"emoticons" : [FSLEmoticon class]};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    /// 赋值
    [_emoticons enumerateObjectsUsingBlock:^(FSLEmoticon *emoticon, NSUInteger idx, BOOL *stop) {
        emoticon.group = self;
    }];
    return YES;
}
@end
