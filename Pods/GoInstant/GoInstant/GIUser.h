//
//  GIUser.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/21/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIUser : NSObject

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSString *idString;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) NSArray *groups;
@property (nonatomic, readonly) NSString *provider;

- (BOOL)isEqualToUser:(GIUser *)user;

@end
