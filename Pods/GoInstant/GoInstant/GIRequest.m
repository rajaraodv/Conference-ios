//
//  GIRequest.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/21/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIRequest.h"
#import "GIRoom.h"
#import "GIKey.h"

@interface GIRequest(Private)
+ (NSString *)commandStringForCommand:(GIRequestCommand)command;
@end

@implementation GIRequest

+ (instancetype)requestWithCommand:(GIRequestCommand)command options:(NSDictionary *)options {
  return [[self alloc] initWithCommand:command options:options];
}

- (instancetype)initWithCommand:(GIRequestCommand)command options:(NSDictionary *)options {
  if (self = [super init]) {
    _command = [GIRequest commandStringForCommand:command];
    _options = (options != nil) ? options : @{ };
  }
  return self;
}

- (NSMutableDictionary *)dictionary {
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  
  [dictionary setObject:_command forKey:@"command"];
  
  [dictionary setObject:_options forKey:@"options"];
  
  if (_room != nil) {
    [dictionary setObject:_room forKey:@"room"];
  }
  
  if (_key != nil) {
    [dictionary setObject:_key forKey:@"key"];
  }
  
  if (_value != nil) {
    [dictionary setObject:_value forKey:@"value"];
  }

  return dictionary;
}

#pragma mark -
#pragma mark Private Interface

+ (NSString *)commandStringForCommand:(GIRequestCommand)command {
  switch (command) {
    case GIRequestCommandGet:
      return @"GET";
    case GIRequestCommandSet:
      return @"SET";
    case GIRequestCommandAdd:
      return @"ADD";
    case GIRequestCommandRemove:
      return @"REMOVE";
    case GIRequestCommandJoin:
      return @"JOIN";
    case GIRequestCommandLeave:
      return @"LEAVE";
    case GIRequestCommandMessage:
      return @"MESSAGE";
    case GIRequestCommandRooms:
      return @"ROOMS";
  }
}

@end
