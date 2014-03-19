//
//  EngineIOClient.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/13/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "EngineIOClient.h"
#import "EngineIOPacket.h"
#import "EngineIOPayload.h"
#import "EngineIOTransportXHR.h"
#import "EngineIOTransportWebSocket.h"
#import "EngineIOError.h"

NSString *const EngineIOErrorDomain = @"com.goinstant.engineIOClient.ErrorDomain";

static NSString *const kDefaultPath = @"engine.io/";

typedef NS_ENUM(NSInteger, EngineIOClientState) {
  EngineIOClientStateDisconnected,
  EngineIOClientStateConnecting,
  EngineIOClientStateConnected
};

@interface EngineIOClient(Private)
- (void)opened:(EngineIOPacket *)packet;
- (void)receivedMessage:(EngineIOPacket *)packet;
- (void)sendPacket:(EngineIOPacket *)packet;
- (void)sendPackets:(NSArray *)packets;
- (void)flush;
- (void)sendPing;
- (void)setPing;
@end

@implementation EngineIOClient {
  // Keep a weak reference to the consumer of received messages.
  __weak id<EngineIODelegate>_delegate;
  
  // The connection used to establish the engine.io handshake.
  NSURLConnection *_handshake;
  // The data received from the engine.io handshake.
  NSMutableData *_handshakeData;
  
  EngineIOClientState _state;
  
  id<EngineIOTransport> _transport;
  id<EngineIOTransport> _upgradeTransport;
  
  // How long to wait in between sent ping messages.
  NSTimeInterval _pingInterval;
  
  // Array of available upgrades (NSString*)
  NSArray *_upgrades;
  
  // Queue for packets waiting to be sent e.g. while upgrading transports
  NSMutableArray *_sendQueue;
}

+ (instancetype)clientWithDelegate:(id)delegate {
  return [[self alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<EngineIODelegate>)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _sendQueue = [NSMutableArray array];
    _state = EngineIOClientStateDisconnected;
    _useSecure = YES;
  }
  return self;
}

#pragma mark -
#pragma mark Connection Interface

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port {
  [self connectToHost:host onPort:port withParams:nil];
}

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params {
  [self connectToHost:host onPort:port withPath:kDefaultPath withParams:params];
}

- (void)connectToHost:(NSString *)host
               onPort:(NSInteger)port
             withPath:(NSString *)path
           withParams:(NSDictionary *)params {
  if (_state != EngineIOClientStateDisconnected) {
    return;
  }
  
  _state = EngineIOClientStateConnecting;

  _host = host;
  _port = port;
  _path = path;
  _params = params;

  _transport = [[EngineIOTransportXHR alloc] initWithDelegate:self];
  [_transport open];
}

- (void)disconnect {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendPing) object:nil];
  _transport.delegate = nil;
  [_transport close];
  _transport = nil;
}

- (void)sendMessage:(NSData *)data {
  EngineIOPacket *packet = [[EngineIOPacket alloc] initWithType:MESSAGE data:data];
  [self sendPacket:packet];
}

#pragma mark -
#pragma mark EngineIOTransportDelegate protocol

- (void)transport:(id<EngineIOTransport>)transport didReceivePacket:(EngineIOPacket *)packet {
  switch (packet.type) {
    case OPEN: // Transport is open
      LOG(@"Received OPEN");
      [self opened:packet];
      break;
    case CLOSE: // Requests a close of the transport
      LOG(@"Received CLOSE");
      [_transport close];
      break;
    case PONG: // Hearbeat pong
      LOG(@"Received PONG");
      if (transport == _upgradeTransport && packet.data != nil) {
        // Check that the packet content was "probe".
        NSString *probe = [[NSString alloc] initWithData:packet.data encoding:NSUTF8StringEncoding];
        if (![probe isEqualToString:@"probe"]) {
          LOG(@"Received invalid pong from upgrade transport. Ignoring.");
          return;
        }
        
        LOG(@"Pausing transport for upgrade");
        
        // This is a probe response from the upgrade transport. Continue the upgrade process by
        // pausing the XHR transport. Once the XHR transport is fully paused (i.e. there are no more
        // outstanding polls) then we'll switch over to the websocket transport. Any messages in the
        // meantime will be queued.
        [_transport pause];
      } else {
        // Regular heartbeat. Schedule the next ping.
        [self setPing];
      }
      break;
    case MESSAGE: // Received application message.
      LOG(@"Received message");
      [self receivedMessage:packet];
      break;
    case NOOP: // NOOP, mostly used for forcing a poll cycle during transport upgrade.
      break;
    case PING:
    case UPGRADE:
      // These packet types are client -> server and should not be received here.
      // TODO : Error handling.
      break;
  }
}

- (void)transport:(id<EngineIOTransport>)transport didFailWithError:(NSError *)error {
  if (transport == _upgradeTransport) {
    LOG(@"Transport failed during upgrade: %@", [error localizedDescription]);
    _upgradeTransport = nil;
    return;
  }
  
  _state = EngineIOClientStateDisconnected;
  if ([_delegate respondsToSelector:@selector(engineIO:didDisconnectWithError:)]) {
    [_delegate engineIO:self didDisconnectWithError:error];
  }
}

- (void)transportDidOpen:(id<EngineIOTransport>)transport {
  if (transport == _upgradeTransport) {
    // When the upgrade transport opens we need to send a PING packet w/ the string "probe" as data
    LOG(@"Sending probe to upgrade transport");
    NSData *probeData = [@"probe" dataUsingEncoding:NSUTF8StringEncoding];
    EngineIOPacket *probe = [[EngineIOPacket alloc] initWithType:PING data:probeData];
    [_upgradeTransport sendPackets:@[ probe ]];
  }
}

- (void)transportDidPause:(id<EngineIOTransport>)transport {
  // We should really only see this during transport upgrading.
  if (transport != _transport) {
    return;
  }
  
  // The upgrade transport failed in the meantime. Just resume the XHR transport.
  if (_upgradeTransport == nil) {
    [transport unpause];
    [self flush];
    return;
  }

  // Close out the XHR transport.
  _transport.delegate = nil;
  [_transport close];
  
  // Mark the upgrade transport as the new transport.
  _transport = _upgradeTransport;
  _upgradeTransport = nil;
  
  // Send the upgrade packet so that engine.io server will flush its cache to the new transport.
  EngineIOPacket *upgradePacket = [[EngineIOPacket alloc] initWithType:UPGRADE];
  [_transport sendPackets:@[ upgradePacket ]];

  // Flush our cache to the new transport.
  [self flush];
  
  LOG(@"Transport upgrade complete");
}

- (void)transportDidClose:(id<EngineIOTransport>)transport {
  if (transport == _upgradeTransport) {
    LOG(@"Upgrade transport closed.");
    _upgradeTransport = nil;
    return;
  }
  
  LOG(@"Main transport closed");
  _state = EngineIOClientStateDisconnected;
  if ([_delegate respondsToSelector:@selector(engineIO:didDisconnectWithError:)]) {
    [_delegate engineIO:self didDisconnectWithError:nil];
  }
}

#pragma mark -
#pragma mark Private methods

- (void)opened:(EngineIOPacket *)packet {
  NSDictionary *json = [packet dataAsJSON];
  
  _sid = [json objectForKey:@"sid"];
  _upgrades = [json objectForKey:@"upgrades"];
  _pingInterval = [[json objectForKey:@"pingInterval"] intValue] / 1000; // pingInterval is in ms
  _pingTimeout = [[json objectForKey:@"pingTimeout"] intValue] / 1000; // pingTimeout is in ms
  
  // Schedule the first ping packet.
  [self setPing];
  
  [self flush];
  
  LOG(@"Handshake complete");
  if ([_delegate respondsToSelector:@selector(engineIODidConnect:)]) {
    [_delegate engineIODidConnect:self];
  }
  
  _state = EngineIOClientStateConnected;
  
  if ([_upgrades containsObject:@"websocket"]) {
    _upgradeTransport = [[EngineIOTransportWebSocket alloc] initWithDelegate:self];
    [_upgradeTransport open];
  }
}

- (void)receivedMessage:(EngineIOPacket *)packet {
  if ([_delegate respondsToSelector:@selector(engineIO:didReceiveMessage:)]) {
    [_delegate engineIO:self didReceiveMessage:packet.data];
  }
}

- (void)sendPacket:(EngineIOPacket *)packet {
  LOG(@"Sending packet type: %d data: %@", packet.type, packet.data);
  [self sendPackets:@[ packet ]];
}

- (void)sendPackets:(NSArray *)packets {
  if (!_transport || ![_transport isReady]) {
    [_sendQueue addObjectsFromArray:packets];
  } else {
    [_transport sendPackets:packets];
  }
}

- (void)flush {
  if (!_transport || ![_transport isReady] || [_sendQueue count] <= 0) {
    return;
  }
  
  [self sendPackets:_sendQueue];
  [_sendQueue removeAllObjects];
}

- (void)sendPing {
  LOG(@"Sending PING");
  EngineIOPacket *packet = [[EngineIOPacket alloc] initWithType:PING];
  [self sendPacket:packet];
}

- (void)setPing {
  LOG(@"Scheduling PING");
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendPing) object:nil];
  [self performSelector:@selector(sendPing) withObject:nil afterDelay:_pingInterval];
}

@end
