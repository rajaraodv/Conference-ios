//
//  GIRoom.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/16/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//


#import "GIRoom.h" 
#import "GIRoom+protected.h"
#import "GIConnection.h"
#import "GIConnection+protected.h"
#import "GIChannel.h"
#import "GIKey.h"
#import "GIRequest.h"
#import "GIUser.h"
#import "GIObserverWrapper.h"
#import "GINotification.h"

@interface GIRoom(Private)
- (void)setJoined:(BOOL)joined;
- (void)receivedNotification:(NSNotification *)notification;
@end

@implementation GIRoom {
  NSMutableSet *_observers;
  NSMutableDictionary *_users;
  GIKey *_usersKey;
}

@synthesize users = _users;

+ (instancetype)roomWithName:(NSString *)name connection:(GIConnection *)connection {
  return [[self alloc] initWithName:name connection:connection];
}

- (instancetype) initWithName:(NSString *)name connection:(GIConnection *)connection {
  if (self = [super init]) {
    _name = name;
    _connection = connection;
    _observers = [NSMutableSet set];
    _usersKey = [self keyWithPath:@"/.users"]; // TODO : This is a retain cycle...
    _users = [NSMutableDictionary dictionary];
    
    NSString *notificationName = [GINotification nameForRoom:self];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(receivedNotification:)
                   name:notificationName
                 object:connection];
  }
  return self;
}

- (void)dealloc {
  NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
  [center removeObserver:self];
}

- (BOOL)isEqualToRoom:(GIRoom *)room {
  if (!room) {
    return NO;
  }
  
  return ([self.name isEqualToString:room.name] && [self.connection isEqualToConnection:room.connection]);
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  
  if (![object isKindOfClass:[GIRoom class]]) {
    return NO;
  }
  
  return [self isEqualToRoom:(GIRoom *)object];
}

- (NSUInteger)hash {
  return [self.name hash] ^ [self.connection hash];
}

#pragma mark -
#pragma mark Join/Leave interface

- (void)join {
  [self joinWithCompletion:nil];
}

- (void)joinWithCompletion:(GIRoomHandler)block {
  LOG(@"Joining room %@", _name);
  GIRequest *request = [GIRequest requestWithCommand:GIRequestCommandJoin options:nil];
  
  request.key = @"/.users";
  
  __block GIRoom *bSelf = self;
  GIResponseHandler completionBlock = ^(NSError *error, NSDictionary *response) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error != nil) {
        if (block != nil) {
          dispatch_group_async([[self connection] resolveCompletionGroup], [[self connection] resolveCompletionQueue], ^{
            block(error);
          });
        }
        return;
      }

      [bSelf setJoined:YES];

      [_usersKey getValueWithCompletion:^(NSError *error, id value, GIGetContext *context) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (error != nil) {
            if (block != nil) {
              dispatch_group_async([[self connection] resolveCompletionGroup], [[self connection] resolveCompletionQueue], ^{
                block(error);
              });
            }
            return; // TODO : Will never have all the users if this happens
          }

          for (NSString *key in value) {
            NSDictionary *dictionary = [value objectForKey:key];
            GIUser *user = [GIUser userWithDictionary:dictionary];
            [_users setObject:user forKey:user.idString];
          }

          if (block != nil) {
            dispatch_group_async([[self connection] resolveCompletionGroup], [[self connection] resolveCompletionQueue], ^{
              block(nil);
            });
          }
        });
      }];
    });
  };
  
  [self sendRequest:request completion:completionBlock];
}

- (void)leave {
  [self leaveWithCompletion:nil];
}

- (void)leaveWithCompletion:(GIRoomHandler)block {
  LOG(@"Leaving room %@", _name);
  GIRequest *request = [GIRequest requestWithCommand:GIRequestCommandLeave options:nil];
  
  request.key = @"/.users";

  __block GIRoom *bSelf = self;
  __block NSMutableDictionary *bUsers = _users;

  GIResponseHandler completionBlock = ^(NSError *error, NSDictionary *response) {
    if (error != nil) {
      [bSelf setJoined:NO];
      [bUsers removeAllObjects];
    }

    if (block != nil) {
      dispatch_group_async([[self connection] resolveCompletionGroup], [[self connection] resolveCompletionQueue], ^{
        block(error);
      });
    }
  };
  
  [self sendRequest:request completion:completionBlock];
}

#pragma mark -
#pragma mark Key/Channel interface

- (GIChannel *)channelWithName:(NSString *)name {
  return [GIChannel channelWithName:name room:self];
}

- (GIKey *)keyWithPath:(NSString *)path {
  return [GIKey keyWithPath:path room:self];
}

#pragma mark -
#pragma mark Event interface

- (void)subscribe:(id<GIRoomObserver>)observer {
  GIObserverWrapper *wrapper = [GIObserverWrapper wrapperWithObserver:observer];
  [_observers addObject:wrapper];
}

- (void)unsubscribe:(id<GIRoomObserver>)observer {
  
}

- (void)unsubscribeAll {
  [_observers removeAllObjects];
}

#pragma mark -
#pragma mark Protected Interface

- (void)sendRequest:(GIRequest *)request completion:(GIResponseHandler)block {
  // TODO : Return error if not joined.
  request.room = _name;
  [_connection send:request completion:block];
}

#pragma mark -
#pragma mark Private Interface

- (void)setJoined:(BOOL)joined {
  _joined = joined;
}

- (void)receivedNotification:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *command = [userInfo objectForKey:@"command"];
  GIUser *user = [GIUser userWithDictionary:[userInfo objectForKey:@"value"]];
  
  // Room events are either JOIN or LEAVE.
  BOOL isJoin = [command isEqualToString:@"JOIN"];
  
  for (GIObserverWrapper *wrapper in _observers) {
    if (wrapper.observer == nil) {
      // TODO : reap deallocated observers
      continue;
    }
    
    if (isJoin) {
      [_users setObject:user forKey:user.idString];
      if ([wrapper.observer respondsToSelector:@selector(room:joinedBy:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [wrapper.observer room:self joinedBy:user];
        });
      }
    } else {
      [_users removeObjectForKey:user.idString];
      if ([wrapper.observer respondsToSelector:@selector(room:leftBy:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [wrapper.observer room:self leftBy:user];
        });
      }
    }
  }
}

@end
