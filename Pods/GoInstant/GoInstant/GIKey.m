//
//  GIKey.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/20/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIKey.h"
#import "GIConnection.h"
#import "GIConnection+protected.h"
#import "GIRoom.h"
#import "GIRoom+protected.h"
#import "GIRequest.h"
#import "GINotification.h"
#import "GIObserverWrapper.h"
#import "GIContext.h"
#import "GIContext+protected.h"
#import "GIOptions.h"
#import "GIOptions+protected.h"

@interface GIKey(Private)

- (void)didReceiveNotification:(NSNotification *)notification;

// Generic interface for sending requests
- (void)sendRequest:(GIRequestCommand)command
              value:(id)value
            options:(NSDictionary *)options
         completion:(GIResponseHandler)block;
@end

@implementation GIKey {
  NSMutableSet *_observers;
}

+ (instancetype)keyWithPath:(NSString *)path room:(GIRoom *)room {
  return [[self alloc] initWithPath:path room:room];
}

- (instancetype)initWithPath:(NSString *)path room:(GIRoom *)room {
  if (self = [super init]) {
    _path = path;
    _room = room;
    _name = [path lastPathComponent];
    _observers = [NSMutableSet set];

    NSString *notificationName = [GINotification nameForKey:self];
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

- (BOOL)isEqualToKey:(GIKey *)key {
  if (!key) {
    return NO;
  }
  
  return ([self.name isEqualToString:key.name] && [self.path isEqualToString:key.path]);
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  
  if (![object isKindOfClass:[GIKey class]]) {
    return NO;
  }
  
  return [self isEqualToKey:(GIKey *)object];
}

- (NSUInteger)hash {
  return [self.name hash] ^ [self.path hash];
}

#pragma mark -
#pragma mark Value methods (accessors and mutators)

- (void)getValueWithCompletion:(GIKeyGetHandler)block {
  if (block == nil) {
    return;
  }

  GIResponseHandler responseBlock = ^(NSError *error, NSDictionary *response) {
    if (error != nil) {
      dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
        block(error, nil, nil);
      });

      return;
    }

    id value = [response objectForKey:@"value"];
    GIGetContext *context = [GIGetContext contextWithDictionary:response room:_room];
    dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
      block(nil, value, context);
    });
  };

  [self sendRequest:GIRequestCommandGet value:nil options:nil completion:responseBlock];
}

- (void)removeValue {
  [self removeValueWithOptions:nil completion:nil];
}

- (void) removeValueWithOptions:(GIRemoveOptions *)options {
  [self removeValueWithOptions:options completion:nil];
}

- (void)removeValueWithCompletion:(GIKeyRemoveHandler)block {
  [self removeValueWithOptions:nil completion:block];
}

- (void)removeValueWithOptions:(GIRemoveOptions *)options completion:(GIKeyRemoveHandler)block {
  if (block == nil) {
    return;
  }

  GIResponseHandler responseBlock = ^(NSError *error, NSDictionary *response) {
    if (error != nil) {
      dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
        block(error, nil, nil);
      });

      return;
    }

    id value = [response objectForKey:@"value"];
    GIRemoveContext *context = [GIRemoveContext contextWithDictionary:response room:_room];
    dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
      block(nil, value, context);
    });
  };

  [self sendRequest:GIRequestCommandRemove value:nil options:[options dictionary] completion:responseBlock];
}

- (void)setValue:(id)value {
  [self setValue:value options:nil completion:nil];
}

- (void)setValue:(id)value options:(GISetOptions *)options {
  [self setValue:value options:options completion:nil];
}

- (void)setValue:(id)value completion:(GIKeySetHandler)block {
  [self setValue:value options:nil completion:block];
}

- (void)setValue:(id)value options:(GISetOptions *)options completion:(GIKeySetHandler)block {
  if (block == nil) {
    return;
  }

  GIResponseHandler responseBlock = ^(NSError *error, NSDictionary *response) {
    if (error != nil) {
      dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
        block(error, nil, nil);
      });

      return;
    }

    id value = [response objectForKey:@"value"];
    GIGetContext *context = [GIGetContext contextWithDictionary:response room:_room];

    dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
      block(nil, value, context);
    });
  };

  [self sendRequest:GIRequestCommandSet value:value options:[options dictionary] completion:responseBlock];
}

- (void)addValue:(id)value {
  [self addValue:value options:nil completion:nil];
}

- (void)addValue:(id)value options:(GISetOptions *)options {
  [self addValue:value options:options completion:nil];
}

- (void)addValue:(id)value completion:(GIKeyAddHandler)block {
  [self addValue:value options:nil completion:block];
}

- (void)addValue:(id)value options:(GISetOptions *)options completion:(GIKeyAddHandler)block {
  if (block == nil) {
    return;
  }

  GIResponseHandler responseBlock = ^(NSError *error, NSDictionary *response) {
    if (error != nil) {
      dispatch_group_async([[_room connection] resolveCompletionGroup], [[_room connection] resolveCompletionQueue], ^{
        block(error, nil, nil);
      });

      return;
    }

    id value = [response objectForKey:@"value"];
    GIAddContext *context = [GIAddContext contextWithDictionary:response room:_room];
    block(nil, value, context);
  };

  [self sendRequest:GIRequestCommandSet value:value options:[options dictionary] completion:responseBlock];
}

#pragma mark -
#pragma mark Traversal Methods

- (GIKey *)childKeyWithName:(NSString *)name {
  return nil;
}

- (GIKey *)descendentKeyWithPath:(NSString *)path {
  return nil;
}

- (GIKey *)parentKey {
  return nil;
}

#pragma mark -
#pragma mark Event methods

- (void)subscribe:(id<GIKeyObserver>)observer {
  GIObserverWrapper *wrapper = [GIObserverWrapper wrapperWithObserver:observer];
  [_observers addObject:wrapper];
}

- (void)unsubscribe:(id<GIKeyObserver>)observer {
}

- (void)unsubscribeAll {
  [_observers removeAllObjects];
}

#pragma mark -
#pragma mark Private Interface

- (void)didReceiveNotification:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];

  id value = [userInfo objectForKey:@"value"];
  NSString *command = [userInfo objectForKey:@"command"];

  for (GIObserverWrapper *wrapper in _observers) {
    if (wrapper.observer == nil) {
      continue;
    }

    // XXX: We do these string comparisons a lot we should pass around enums wherever we can.
    // TODO: implement GIContext
    if ([command isEqualToString:@"SET"]) {
      GIGetContext *context = [GIGetContext contextWithDictionary:userInfo room:_room];
      if ([wrapper.observer respondsToSelector:@selector(key:valueSet:context:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [wrapper.observer key:self valueSet:value context:context];
        });
      }

    } else if ([command isEqualToString:@"ADD"]) {
      GIAddContext *context = [GIAddContext contextWithDictionary:userInfo room:_room];
      if ([wrapper.observer respondsToSelector:@selector(key:valueAdded:context:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [wrapper.observer key:self valueAdded:value context:context];
        });
      }

    } else if ([command isEqualToString:@"REMOVE"]) {
      GIRemoveContext *context = [GIRemoveContext contextWithDictionary:userInfo room:_room];
      if ([wrapper.observer respondsToSelector:@selector(key:valueRemoved:context:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [wrapper.observer key:self valueRemoved:value context:context];
        });
      }

    } else {
      LOG(@"NSNotification with unhandled command passed: %@", command);
    }
  }
}

- (void)sendRequest:(GIRequestCommand)command
              value:(id)value
            options:(NSDictionary *)options
         completion:(GIResponseHandler)block {

  GIRequest *request = [GIRequest requestWithCommand:command options:options];
  request.value = value;
  request.key = _path;

  [_room sendRequest:request completion:block];
}

@end
