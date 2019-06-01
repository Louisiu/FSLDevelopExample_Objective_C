//
//  FSLHTTPResponse.h
//  FSLDevelopExample
//
//  Created by Fingal Liu on 2019/6/1.
//  Copyright © 2019 Fingal Liu. All rights reserved.
//

#import "FSLObject.h"
/// 请求数据返回的状态码
typedef NS_ENUM(NSUInteger, FSLHTTPResponseCode) {
    FSLHTTPResponseCodeSuccess = 100 ,                     /// 请求成功
    FSLHTTPResponseCodeNotLogin = 666,                     /// 用户尚未登录
    FSLHTTPResponseCodeParametersVerifyFailure = 105,      /// 参数验证失败
};

@interface FSLHTTPResponse : FSLObject
/// The parsed FSLObject object corresponding to the API response.
/// The developer need care this data 切记：若没有数据是NSNull 而不是nil .对应于服务器json数据的 data
@property (nonatomic, readonly, strong) id parsedResult;
/// 自己服务器返回的状态码 对应于服务器json数据的 code
@property (nonatomic, readonly, assign) FSLHTTPResponseCode code;
/// 自己服务器返回的信息 对应于服务器json数据的 code
@property (nonatomic, readonly, copy) NSString *msg;


// Initializes the receiver with the headers from the given response, and given the origin data and the
// given parsed model object(s).
- (instancetype)initWithResponseObject:(id)responseObject parsedResult:(id)parsedResult;
@end
