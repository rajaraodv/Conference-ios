//
//  GIUser.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/21/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIUser.h"

@implementation GIUser

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary {
  return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
  if (self = [super init]) {
    _displayName = [dictionary objectForKey:@"displayName"];
    _provider = [dictionary objectForKey:@"provider"];
    _idString = [dictionary objectForKey:@"id"];
    // TODO : Groups
  }
  return self;
}

- (BOOL)isEqualToUser:(GIUser *)user {
  if (!user) {
    return NO;
  }
  
  return ([self.idString isEqualToString:user.idString]);
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  
  if (![object isKindOfClass:[GIUser class]]) {
    return NO;
  }
  
  return [self isEqualToUser:(GIUser *)object];
}

- (NSUInteger)hash {
  return [self.idString hash];
}

@end
