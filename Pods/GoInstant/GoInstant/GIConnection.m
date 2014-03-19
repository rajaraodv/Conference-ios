//
//  GIConnection.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/17/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIConnection.h"
#import "GIConnection+protected.h"
#import "GIError+protected.h"
#import "GISocket.h"
#import "GIRoom.h"
#import "GIUser.h"
#import "GIRequest.h"
#import "GINotification.h"
#import "GIObserverWrapper.h"

// Time (in seconds) before requests time out.
static NSInteger kRequestExpiryTime = 5;

@interface GIConnection(Private)
- (BOOL)verifyConnectUrl;
- (void)receivedWithError:(NSString *)error response:(NSDictionary *)response;
- (void)receivedNotify:(NSDictionary *)response;
- (void)requestTimedOut:(NSNumber *)callbackId;
@end

@implementation GIConnection {
  NSURL *_connectUrl;
  GISocket *_socket;
  GIConnectionHandler _connectionBlock;
  NSMutableSet *_observers;
  GIUser *_user;
  NSMutableDictionary *_callbacks;
  NSInteger _currentCallback;
}

#pragma mark -
#pragma mark Dispatch Declarations

static dispatch_group_t gi_connection_group() {
  static dispatch_group_t gi_connection_group;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    gi_connection_group = dispatch_group_create();
  });

  return gi_connection_group;
};

- (dispatch_queue_t)resolveCompletionQueue {
  return _completionQueue ?: dispatch_get_main_queue();
}

- (dispatch_group_t)resolveCompletionGroup {
  return _completionGroup ?: gi_connection_group();
}

#pragma mark -
#pragma mark Initialization Interface

+ (instancetype)connectionWithConnectUrl:(NSURL *)connectUrl {
  return [[self alloc] initWithConnectUrl:connectUrl];
}

- (instancetype)initWithConnectUrl:(NSURL *)connectUrl {
  if (self = [super init]) {
    _connectUrl = connectUrl;
    _socket = [GISocket socketWithConnection:self];
    _callbacks = [NSMutableDictionary dictionary];
    _observers = [NSMutableSet set];

    if (![self verifyConnectUrl]) {
      LOG(@"Failed to validate connection URL");
      [NSException raise:@"Invalid connect URL" format:@"connect URL %@ is invalid", connectUrl];
      return nil;
    }
  }
  return self;
}

- (void)dealloc {
  [self disconnect];
}

- (BOOL)isEqualToConnection:(GIConnection *)connection {
  if (!connection) {
    return NO;
  }
  
  return ([self.host isEqualToString:connection.host] && [self.account isEqualToString:connection.account] && [self.app isEqualToString:connection.app]);
}

- (BOOL)isEqual:(id)object {
  if (self == object) {
    return YES;
  }
  
  if (![object isKindOfClass:[GIConnection class]]) {
    return NO;
  }
  
  return [self isEqualToConnection:(GIConnection *)object];
}

- (NSUInteger)hash {
  return [self.host hash] ^ [self.account hash] ^ [self.app hash];
}

#pragma mark -
#pragma mark Connect Interface

- (void)connect {
  [self connectWithCompletion:nil];
}

- (void)connectWithCompletion:(GIConnectionHandler)block {
  _connectionBlock = block;
  [_socket connect];
}

- (void)connectWithJwt:(NSString *)jwt {
  [self connectWithJwt:jwt completion:nil];
}

- (void)connectWithJwt:(NSString *)jwt completion:(GIConnectionHandler)block {
  if (![self verifyConnectUrl]) {
    // TODO Error handling
    LOG(@"Failed to validate connection URL");
    return;
  }

  _connectionBlock = block;
  [_socket connectWithJwt:jwt];
}

- (void)connectAndJoinRoom:(NSString *)room jwt:(NSString *)jwt completion:(GIConnectionRoomHandler)block {
  GIRoom * __weak _room = [self roomWithName:room];

  [self connectWithJwt:jwt completion:^(NSError *error, GIConnection *connection) {
    // When calling internal methods which may potentially return a completion on a provided dispatch
    // make sure we're running on the main thread. Otherwise we will end up putting internal work on an external dispatch.
    // TODO: Investigate delegating all internal work to a SERIAL queue off the main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error != nil) {
        dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
          block(error, nil, nil);
        });

        return;
      }

      [_room joinWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (error != nil) {
            dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
              block(error, nil, nil);
            });

            return;
          }

          dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
            block(nil, connection, _room);
          });
        });
      }];
    });
  }];
}

- (void)connectAndJoinRoom:(NSString *)room completion:(GIConnectionRoomHandler)block {
  GIRoom *__weak _room = [self roomWithName:room];

  [self connectWithCompletion:^(NSError *error, GIConnection *connection) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error != nil) {
        dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
          block(error, nil, nil);
        });

        return;
      }

      [_room joinWithCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (error != nil) {
            block(error, nil, nil);
            return;
          }

          dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
            block(nil, connection, _room);
          });
        });
      }];
    });
  }];
}

- (void)roomsWithCompletion:(GIConnectionRoomsHandler)block {
  if (block == nil) {
    return;
  }

  GIRequest *request = [GIRequest requestWithCommand:GIRequestCommandRooms options:nil];
  [self send:request completion:^(NSError *error, NSDictionary *response) {
    if (error != nil) {
      dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
        block(error, nil);
      });

      return;
    }

    NSArray *rooms = [response valueForKey:@"value"];
    NSMutableArray *result = [NSMutableArray array];

    [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [result addObject:[GIRoom roomWithName:obj connection:self]];
    }];

    dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
      block(nil, [NSArray arrayWithArray:result]);
    });
  }];
}

- (void) disconnect {
  [_socket disconnect];
}

#pragma mark -
#pragma mark Traversal Interface

- (GIRoom *)roomWithName:(NSString *)name {
  return [GIRoom roomWithName:name connection:self];
}

#pragma mark -
#pragma mark Observer Interface

- (void)subscribe:(id<GIConnectionObserver>)observer {
  GIObserverWrapper *wrapper = [GIObserverWrapper wrapperWithObserver:observer];
  [_observers addObject:wrapper];
}

- (void)unsubscribe:(id<GIConnectionObserver>)observer {
}

- (void)unsubscribeAll {
  [_observers removeAllObjects];
}

#pragma mark -
#pragma mark Protected Methods

- (void)didAuthAsUser:(NSDictionary *)user {
  _user = [GIUser userWithDictionary:user];

  if (_connectionBlock) {
    dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
      _connectionBlock(nil, self);
      _connectionBlock = nil;
    });
  }

  for (GIObserverWrapper *wrapper in _observers) {
    if (wrapper.observer == nil ||
        ![wrapper.observer respondsToSelector:@selector(connectionDidConnect:)]) {
      continue;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [wrapper.observer connectionDidConnect:self];
    });
  }
}

- (void)didReceiveJSON:(id)json {
  NSArray *received = json;
  
  NSString *type = [received objectAtIndex:0];

  if ([type isEqualToString:@"RESPONSE"]) {
    [self receivedWithError:[received objectAtIndex:1] response:[received objectAtIndex:2]];
  } else if ([type isEqualToString:@"NOTIFY"]) {
    [self receivedNotify:[received objectAtIndex:1]];
  }
}

- (void)send:(GIRequest *)request completion:(GIResponseHandler)block {
  NSMutableDictionary *dictionary = [request dictionary];
  
  // Create a callback number for this request and store it in the request.
  NSNumber *callbackId = [NSNumber numberWithInt:_currentCallback++];
  [dictionary setObject:callbackId forKey:@"callbackId"];
  
  if (block != nil) {
    // Store the callback indexed by the callback number.
    [_callbacks setObject:block forKey:callbackId];
    
    // Time out the request after a certain amount of time.
    [self performSelector:@selector(requestTimedOut:)
               withObject:callbackId
               afterDelay:kRequestExpiryTime];
  }

  [_socket sendJSON:dictionary];
}

- (void)didDisconnect {
  for (GIObserverWrapper *wrapper in _observers) {
    if (wrapper.observer == nil ||
        ![wrapper.observer respondsToSelector:@selector(connectionDidDisconnect:)]) {
      continue;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [wrapper.observer connectionDidDisconnect:self];
    });
  }
}

- (void)didError:(NSError *)error {
  if (_connectionBlock) {
    dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
      _connectionBlock(error, nil);
      _connectionBlock = nil;
    });
  }

  for (GIObserverWrapper *wrapper in _observers) {
    if (wrapper.observer == nil ||
        ![wrapper.observer respondsToSelector:@selector(connectionDidError:connection:)]) {
      continue;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [wrapper.observer connectionDidError:error connection:self];
    });
  }
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)verifyConnectUrl {
  
  NSString *host;
  if ((host = [_connectUrl host]) == nil) {
    LOG(@"Missing host from connectUrl");
    return NO;
  }
  
  // TODO : Verify goinstant host with regex here.
  
  NSArray *path = [_connectUrl pathComponents];
  if ([path count] < 3) { // The first pathComponent is "/", second is acct and third is app
    LOG(@"Missing account or app from connectUrl");
    return NO;
  }
  
  _host = host;
  _account = path[1];
  _app = path[2];
  
  LOG(@"Parsed host: [%@] account: [%@] app: [%@]", _host, _account, _app);
  return YES;
}

- (void)receivedWithError:(NSString *)error response:(NSDictionary *)response {
  NSNumber *callbackId = [response objectForKey:@"callbackId"];
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(requestTimedOut:)
                                             object:callbackId];
  
  GIResponseHandler handler = [_callbacks objectForKey:callbackId];
  
  if (handler == nil) {
    return;
  }

  if (error != nil && ![error isKindOfClass:[NSNull class]]) {
    NSDictionary *meta = [response objectForKey:@"meta"];
    NSNumber *code = [meta objectForKey:@"code"];

    dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
      handler([GIError errorWithInteger:[code intValue] message:error],  nil);
    });

    return;
  }

  NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:response];
  [mutableResponse removeObjectForKey:@"callbackId"];

  dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
    handler(nil, mutableResponse);
    [_callbacks removeObjectForKey:callbackId];
  });
}

- (void)receivedNotify:(NSDictionary *)notify {
  NSString *command = [notify objectForKey:@"command"];
  NSString *room = [notify objectForKey:@"room"];
  NSString *key = [notify objectForKey:@"key"];
  
  NSString *notificationName;
  
  if ([command isEqualToString:@"JOIN"] || [command isEqualToString:@"LEAVE"]) {
    notificationName = [GINotification nameForRoomWithString:room connection:self];
  } else if ([command isEqualToString:@"MESSAGE"]) {
    notificationName = [GINotification nameforChannelWithString:key roomName:room connection:self];
  } else {
    notificationName = [GINotification nameforKeyWithString:key roomName:room connection:self];
  }
  
  LOG(@"Posting notification with name: %@", notificationName);

  dispatch_async(dispatch_get_main_queue(), ^{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:notificationName object:self userInfo:notify];
  });
}

- (void)requestTimedOut:(NSNumber *)callbackId {
  GIResponseHandler handler = [_callbacks objectForKey:callbackId];
  
  if (handler == nil) {
    return;
  }

  NSError *error = [GIError errorWithEnum:GIConnectionError message:@"Request timed out"];

  dispatch_group_async([self resolveCompletionGroup], [self resolveCompletionQueue], ^{
    handler(error, nil);
    [_callbacks removeObjectForKey:callbackId];
  });
}

@end
