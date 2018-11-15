//
//  AMModel.m
//  BaiBaoBox
//
//  Created by AM on 2017/12/21.
//  Copyright © 2017年 AM. All rights reserved.
//

#import "AMModel.h"
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>

@implementation AMModel

#pragma mark - 创建单利的AFHTTPSessionManager对象
- (AFHTTPSessionManager *)getHttpManager {
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    });

    return manager;
}

- (void)send:(AMModelSendBlock)result {
    [self sendSuccess:^(AMModel *protocol) {
        if (protocol.isSuccessful) {
            result(YES, protocol, protocol.msg);
        } else {
            result(NO, protocol, protocol.msg);
        }
    }
        failure:^(NSString *error) {
            result(NO, self, @"");
        }];
}

- (void)sendSuccess:(AMModelSuccessBlock)success failure:(AMModelFailureBlock)failure {
    AFHTTPSessionManager *manager = [self getHttpManager];

    NSDictionary *parameters = [self createRequest];
    NSLog(@"\n发送协议[%@]发送URL:%@,发送内容\n%@", [self description], self.protocolUrl, [parameters mj_JSONString]);

    if ([self method] == AMHttpPost) {
        [manager POST:self.protocolUrl
            parameters:parameters
            progress:^(NSProgress *_Nonnull uploadProgress) {

            }
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                [self handleResponse:responseObject success:success];
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                [self handleError:error failure:failure];

            }];

    } else if ([self method] == AMHttpGet) {
        [manager GET:self.protocolUrl
            parameters:parameters
            progress:^(NSProgress *_Nonnull downloadProgress) {

            }
            success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
                [self handleResponse:responseObject success:success];
            }
            failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                [self handleError:error failure:failure];
            }];
    }
}
- (void)handleResponse:(id _Nullable)responseObject success:(AMModelSuccessBlock)success {
    if ([NSJSONSerialization isValidJSONObject:responseObject]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"接收协议[%@],接收内容\n[%@]", [self description], json);
    }
    [self parseResponse:responseObject];
    if (success) {
        success(self);
    }
}

- (void)handleError:(NSError *_Nonnull)error failure:(AMModelFailureBlock)failure {
    NSLog(@"%@出错了，错误信息%@", self, error);
    if (failure) {
        failure([error description]);
    }
}

#pragma mark 过滤掉空字符串和数字的属性
- (void)removeDefaultKeys:(NSMutableDictionary *)filterParams {
    [filterParams removeObjectForKey:@"isSuccessful"];
    [filterParams removeObjectForKey:@"method"];
    [filterParams removeObjectForKey:@"protocolUrl"];
}

- (NSDictionary *)createRequest {
    NSMutableDictionary *filterParams = [NSMutableDictionary dictionary];
    NSDictionary *keyValues = [self mj_keyValues];

    [keyValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            if (![self isEmpty:obj]) {
                [filterParams setValue:obj forKey:key];
            }
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            NSNumber *number = obj;
            if ((NSNull *) number != [NSNull null] && (number != nil)) {
                [filterParams setValue:obj forKey:key];
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = obj;
            if ((NSNull *) arr != [NSNull null] && arr) {
                [filterParams setValue:obj forKey:key];
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = obj;
            if ((NSNull *) dic != [NSNull null] && (dic)) {
                [filterParams setValue:obj forKey:key];
            }
        }

    }];
    [self removeDefaultKeys:filterParams];

    return filterParams;
}

- (BOOL)isEmpty:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (string.length == 0) {
        return YES;
    }

    return NO;
}

- (BOOL)isSuccessful {
    return [[NSString stringWithFormat:@"%@", self.state] isEqualToString:@"0"];
}

#pragma mark 根据字典解析对象
- (void)parseResponse:(NSDictionary *)response {
    [self mj_setKeyValues:response];
}

- (NSString *)protocolUrl {
    return @"";
}

- (AMHttp)method {
    return AMHttpPost;
}

- (NSString *)description {
    return @"协议基类";
}

+(NSDictionary *)mj_replacedKeyFromPropertyName {
        return @{ @"ID" : @"id" };
    
}

@end

