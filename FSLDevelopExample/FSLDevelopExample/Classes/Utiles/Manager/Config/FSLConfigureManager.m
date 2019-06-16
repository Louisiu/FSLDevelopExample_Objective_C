//
//  FSLConfigureManager.m
//  WeChat
//
//  Created by Fingal Liu on 2017/11/26.
//  Copyright © 2017年 Fingal Liu. All rights reserved.
//

#import "FSLConfigureManager.h"

///
static NSString *is_formal_setting = nil;
static NSString *is_use_https = nil;
static NSString *is_appStore_formal_setting = nil;

/// (AppStore环境的key)
static NSString * const FSLApplicationAppStoreFormalSettingKey = @"FSLApplicationAppStoreFormalSettingKey";
/// 正式环境key
static NSString * const FSLApplicationFormalSettingKey = @"FSLApplicationFormalSettingKey";
/// 使用Httpskey
static NSString * const FSLApplicationUseHttpsKey = @"FSLApplicationUseHttpsKey";

@implementation FSLConfigureManager
/// 公共配置
+ (void)configure{
    /// 初始化一些公共配置...
    
}

+ (void)setApplicationFormalSetting:(BOOL)formalSetting{
    is_formal_setting = formalSetting?@"1":@"0";
    [[NSUserDefaults standardUserDefaults] setObject:is_formal_setting forKey:FSLApplicationFormalSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)applicationFormalSetting{
#if DEBUG
    if (!is_formal_setting) {
        is_formal_setting = [[NSUserDefaults standardUserDefaults] objectForKey:FSLApplicationFormalSettingKey];
        is_formal_setting = [is_formal_setting fsl_stringValueExtension];
    }
    return (is_formal_setting.integerValue == 1);
#else
    /// Release 模式下默认
    return YES;
#endif
}


+ (void)setApplicationAppStoreFormalSetting:(BOOL)formalSetting{
    is_appStore_formal_setting = formalSetting?@"1":@"0";
    [[NSUserDefaults standardUserDefaults] setObject:is_appStore_formal_setting forKey:FSLApplicationAppStoreFormalSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)applicationAppStoreFormalSetting{
#if DEBUG
    if (!is_appStore_formal_setting) {
        is_appStore_formal_setting = [[NSUserDefaults standardUserDefaults] objectForKey:FSLApplicationAppStoreFormalSettingKey];
        is_appStore_formal_setting = [is_appStore_formal_setting fsl_stringValueExtension];
    }
    return (is_appStore_formal_setting.integerValue == 1);
#else
    /// Release 默认是AppStore环境
    return YES;
#endif
}

+ (void)setApplicationUseHttps:(BOOL)useHttps{
    is_use_https = useHttps?@"1":@"0";
    [[NSUserDefaults standardUserDefaults] setObject:is_use_https forKey:FSLApplicationUseHttpsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)applicationUseHttps{
#if DEBUG
    if (!is_use_https) {
        is_use_https = [[NSUserDefaults standardUserDefaults] objectForKey:FSLApplicationUseHttpsKey];
        /// 正式环境
        if ([self applicationFormalSetting]) {
            /// 默认如果是nil 则加载Https
            if (is_use_https == nil) {
                is_use_https = @"1";
            }
        }
        is_use_https = [is_use_https fsl_stringValueExtension];
    }
    return (is_use_https.integerValue == 1);
#else
    /// Release 默认是AppStore环境
    return YES;
#endif
}



/// 请求的baseUrl
+ (NSString *)requestBaseUrl{
    if ([self applicationFormalSetting]){
        /// 注意：这里针对你项目中请求baseUrl来处理....
        if ([self applicationAppStoreFormalSetting]) {
            /// AppStore正式环境
            NSLog(@"￥￥￥￥￥￥￥￥ AppStore正式环境 ￥￥￥￥￥￥￥￥");
            return [self applicationUseHttps] ? @"https://live.9158.com/":@"https://live.9158.com/";
        }else{
            /// 测试正式环境
            NSLog(@"￥￥￥￥￥￥￥￥ 测试正式环境 ￥￥￥￥￥￥￥￥");
            return [self applicationUseHttps] ? @"https://live.9158.com/":@"https://live.9158.com/";
        }
    } else {
        /// 测试环境
        NSLog(@"￥￥￥￥￥￥￥￥ 测试环境 ￥￥￥￥￥￥￥￥");
        return [self applicationUseHttps] ?@"https://live.9158.com/":@"https://live.9158.com/";
    }
}
@end
