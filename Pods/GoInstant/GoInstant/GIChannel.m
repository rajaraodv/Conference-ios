//
//  GIChannel.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/16/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIChannel.h"
#import "GIConnection.h"
#import "GIConnection+protected.h"
#import "GIRoom.h"
#import "GIRoom+protected.h"
#import "GIRequest.h"
#import "GIObserverWrapper.h"
#import "GINotification.h"
#import "GIOptions.h"
#import "GIOptions+protected.h"

@interface GIChannel(Private)
- (void)didReceiveNotification:(NSNotification *)notification;
@end

@implementation GIChannel {
  NSMutableSet *_observers;
}

+ (instancetype)channelWithName:(NSString *)name room:(GIRoom *)room {
  return [[self alloc] initWithName:name room:room];
}

- (instancetype)initWithName:(NSString *)name room:(GIRoom*)room {
  if (self = [super init]) {
    _name = name;
    _room = room;
    _observers = [NSMutableSet set];
    
    NSString *notificationName = [GINotification nameForChannel:self];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didReceiveNotification:)
                   name:notificationName
                 object:_room.connection];
  }
  return self;
}

- (void)dealloc {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center removeObserver:self];
}

- (void)sendMessage:(id)message {
  [self sendMessage:message options:nil completion:nil];
}

- (void)sendMessage:(id)message options:(GIOptions *)options {
  [self sendMessage:message options:options completion:nil];
}

- (void)sendMessage:(id)message completion:(GIChannelHandler)block {
  [self sendMessage:message options:nil completion:block];
}

- (void)sendMessage:(id)message options:(GIOptions *)options
     completion:(GIChannelHandler)block {

  GIRequest *request = [GIRequest requestWithCommand:GIRequestCommandMessage
                                             options:[options dictionary]];

  request.key = [NSString stringWithFormat:@"/%@", _name];
  request.value = message;
  [_room sendRequest:request completion:^(NSError *error, NSDictionary *response) {
    if (block != nil) {
      dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
        block(error);
      });
    }
  }];
}

- (void)subscribe:(id<GIChannelObserver>)observer {
  GIObserverWrapper *wrapper = [GIObserverWrapper wrapperWithObserver:observer];
  [_observers addObject:wrapper];
}

- (void)unsubscribe:(id<GIChannelObserver>)observer {
  
}

- (void)unsubscribeAll {
  [_observers removeAllObjects];
}

- (BOOL)isEqualToChannel:(GIChannel *)channel {
  if (!channel) {
    return NO;
  }
  
  return ([self.name isEqualToString:channel.name]);
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  
  if (![object isKindOfClass:[GIChannel class]]) {
    return NO;
  }
  
  return [self isEqualToChannel:(GIChannel *)object];
}

- (NSUInteger)hash {
  return [self.name hash];
}

#pragma mark -
#pragma mark Private Interface

- (void)didReceiveNotification:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  id value = [userInfo objectForKey:@"value"];
  NSString *userId = [userInfo objectForKey:@"userId"];
  
  GIUser *fromUser = [_room.users objectForKey:userId];
  
  for (GIObserverWrapper *wrapper in _observers) {
    if (wrapper.observer == nil) {
      // TODO : reap deallocated observers
      continue;
    }
    
    if ([wrapper.observer respondsToSelector:@selector(channel:didReceiveMessage:fromUser:)]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [wrapper.observer channel:self didReceiveMessage:value fromUser:fromUser];
      });
    }
  }
}

@end
