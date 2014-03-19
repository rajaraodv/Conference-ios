//
//  GIError+protected.h
//  GoInstant
//
//  Created by Jeremy Wright on 2/17/14.
//  Copyright (c) 2014 Jeremy Wright. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GIError.h"

@interface GIError : NSObject
+ (NSError *)errorWithEnum:(GIErrorCode)errorCode;
+ (NSError *)errorWithEnum:(GIErrorCode)errorCode message:(NSString *)message;
+ (NSError *)errorWithInteger:(NSInteger)errorCode;
+ (NSError *)errorWithInteger:(NSInteger)errorCode message:(NSString *)message;
@end