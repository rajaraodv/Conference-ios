//
//  GIError.m
//  GoInstant
//
//  Created by Jeremy Wright on 2/17/14.
//  Copyright (c) 2014 Jeremy Wright. All rights reserved.
//

#import "GIError+protected.h"

static NSString * const kDomain = @"com.goinstant";

@implementation GIError
+ (NSError *)errorWithEnum:(GIErrorCode)errorCode {
  return [self errorWithInteger:errorCode message:nil];
}

+ (NSError *)errorWithEnum:(GIErrorCode)errorCode message:(NSString *)message {
  return [self errorWithInteger:errorCode message:message];
}

+ (NSError *)errorWithInteger:(NSInteger)errorCode {
  return [self errorWithInteger:errorCode message:nil];
}

+ (NSError *)errorWithInteger:(NSInteger)errorCode message:(NSString *)message {
  NSDictionary *userInfo = @{
    NSLocalizedDescriptionKey: message,
  };

  return [NSError errorWithDomain:kDomain code:errorCode userInfo:userInfo];
}

#pragma mark -
#pragma mark Private Interface
@end