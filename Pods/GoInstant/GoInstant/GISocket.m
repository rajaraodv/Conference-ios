//
//  GISocket.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/16/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GISocket.h"
#import "GIConnection.h"
#import "GIConnection+protected.h"
#import "GIError+protected.h"
#import "Backoff.h"


// The JWT length limit for including it in the connection query. Any JWT beyond this size will be
// sent in a separate AUTH message instead (resulting in slightly slower connection time).
static NSInteger TOKEN_URL_LIMIT = 700;

static NSString *const kPathFormat = @"%@/%@/";

typedef NS_ENUM(NSInteger, SocketState) {
  // The socket is initialized but has not been asked to connect.
  INITIALIZED,
  
  // The socket is connecting and does not need to send an AUTH packet after connection.
  CONNECTING,
  
  // The socket is connecting and must send an AUTH packet after connection.
  CONNECTING_WITH_AUTH,
  
  // The socket is connected, has sent the AUTH packet (if required), and is waiting to receive the
  // USER message.
  AUTHORIZING,
  
  // The socket has connected and authorized and is ready to use.
  CONNECTED
};

@implementation GISocket {
  __weak GIConnection *_connection;
  EngineIOClient *_eio;
  SocketState _state;
  NSString *_token;
  Backoff *_backoff;
}

+ (instancetype)socketWithConnection:(GIConnection *)connection {
  return [[self alloc] initWithConnection:connection];
}

- (instancetype)initWithConnection:(GIConnection *)connection {
  if (self = [super init]) {
    _connection = connection;
    
    _eio = [EngineIOClient clientWithDelegate:self];
    _eio.useSecure = YES;
    _state = INITIALIZED;
    
    _backoff = [Backoff backoff];
    _backoff.delegate = self;
  }
  
  return self;
}

- (void)dealloc {
  [self disconnect];
}

- (void)connect {
  NSNumber *guest = [NSNumber numberWithBool:YES];
  NSDictionary *params = [NSDictionary dictionaryWithObject:guest forKey:@"guest"];
  
  NSString *path = [NSString stringWithFormat:kPathFormat, _connection.account, _connection.app];
  [_eio connectToHost:_connection.host onPort:443 withPath:path withParams:params];
  _state = CONNECTING;
}

- (void)connectWithJwt:(NSString *)jwt {
  NSDictionary *params;
  
  _token = jwt;
  
  if (jwt.length > TOKEN_URL_LIMIT) {
    _state = CONNECTING_WITH_AUTH;
  } else {
    params = [NSDictionary dictionaryWithObject:jwt forKey:@"jwt"];
    _state = CONNECTING;
  }
  
  NSString *path = [NSString stringWithFormat:kPathFormat, _connection.account, _connection.app];
  [_eio connectToHost:_connection.host onPort:443 withPath:path withParams:params];
}

- (void)disconnect {
  [_eio disconnect];
  [_backoff reset];
  _state = INITIALIZED;
}

- (void)sendJSON:(id)json {
  if (![NSJSONSerialization isValidJSONObject:json]) {
    LOG(@"Could not send invalid JSON object, ignoring.");
    return;
  }
  
  NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
  
#ifdef DEBUG
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  LOG(@"Sending message: %@", string);
#endif
  
  [_eio sendMessage:data];
}

#pragma mark -
#pragma mark EngineIODelegate protocol

- (void)engineIODidConnect:(EngineIOClient *)engine {
  [_backoff reset];
  
  if (_state == CONNECTING) {
    _state = AUTHORIZING;
  } else if (_state == CONNECTING_WITH_AUTH) {
    NSArray *auth = @[ @"AUTH", _token ];
    [self sendJSON:auth];
    
    _state = AUTHORIZING;
  } else {
    // TODO : Should not be in any other state: error handling
  }
}

- (void)engineIO:(EngineIOClient *)client didDisconnectWithError:(NSError *)error {
  LOG(@"EngineIO disconnected, starting backoff reconnect logic");

  [_backoff start];

  if (_state == CONNECTED) {
    // Only notify after a disconnection, not if we're already disconnected.
    [_connection didDisconnect];
  }
}

- (void)engineIO:(EngineIOClient *)client didReceiveMessage:(NSData *)message {
  NSError *error;
  id json = [NSJSONSerialization JSONObjectWithData:message options:0 error:&error];
  
  if (json == nil) {
    // TODO : Error handling
  }
  
  // The authorizing state indicates that we connected as a guest and are now waiting for the USER
  // message to arrive with our guest user details.
  if (_state == AUTHORIZING) {
    NSString *type = [json objectAtIndex:0];
    if ([type isEqualToString:@"USER"]) {
      NSDictionary *user = [json objectAtIndex:1];
      
      // When authenticating as a guest the generated guest token is returned in the USER message.
      if ([json count] > 3 && _token == nil) {
        _token = [json objectAtIndex:3]; // index 2 is 'unused_value'
      }
        
      [_connection didAuthAsUser:user];
      
      _state = CONNECTED;
    } else if ([type isEqualToString:@"ERROR"]) {
      // TODO: Error handling
      GIErrorCode code = [[json objectAtIndex:2] integerValue];
      NSString *message = [json objectAtIndex:1];
      [_connection didError:[GIError errorWithEnum:code message:message]];

      // Not a disconnect, this is a general connection error.
      // Backoffs don't apply here. Errors at this stage are almost guaranteed to be unrecoverable. (Auth, down service etc).
      [_backoff reset];
      [_eio disconnect];
      _state = INITIALIZED;
    }
    
    // Ignore any other messages received during the authorizing state.
    return;
  }
  
  [_connection didReceiveJSON:json];
}

#pragma mark -
#pragma mark BackoffDelegate protocol

- (void)backoffDidFinish:(Backoff *)backoff {
  LOG(@"Backoff fired, attempting to reconnect");
  if (_token) {
    [self connectWithJwt:_token];
  } else {
    [self connect];
  }
}

- (void)backoffDidReachMaxAttempts:(Backoff *)backoff {
  NSString *message = @"Too many connection attempts. Connection failed.";
  LOG(message);

  [_connection didError:[GIError errorWithEnum:GIConnectionError message:message]];
}

@end
