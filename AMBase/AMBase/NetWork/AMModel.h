
//
//  AMModel.h
//  BaiBaoBox
//
//  Created by AM on 2017/12/21.
//  Copyright © 2017年 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AMModelSuccessBlock)(id protocol);
typedef void (^AMModelFailureBlock)(NSString *error);
typedef void (^AMModelSendBlock)(BOOL isSuccessful, id protocol, NSString *msg);

typedef enum : NSUInteger {
    AMHttpPost,
    AMHttpGet,
} AMHttp;

static inline NSString *requestUrl(NSString *host, NSString *path, NSString *file) {
    return [NSString stringWithFormat:@"%@%@%@", host, path ? path : @"", file ? file : @""];
}

@interface AMModel : NSObject

@property (nonatomic, copy) NSString *error;
@property (nonatomic, copy) NSString *protocolUrl;
@property (nonatomic, assign) AMHttp method;

@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, assign) BOOL isSuccessful;

- (void)send:(AMModelSendBlock)result;

@end

