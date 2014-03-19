//
//  EngineIOTransportWebSocket.m
//  EngineIOClient
//
//  Created by Matthew Creaser on 1/29/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "EngineIOTransportWebSocket.h"
#import "EngineIOPacket.h"
#import "EngineIOError.h"

static NSString *const kUrlFormat = @"%@://%@/%@?transport=websocket&EIO=2&sid=%@";
static NSString *const kUrlPortFormat = @"%@://%@:%d/%@?transport=websocket&EIO=2&sid=%@";

@implementation EngineIOTransportWebSocket {
  __weak id<EngineIOTransportDelegate> _delegate;
  SRWebSocket *_webSocket;
}

@synthesize delegate = _delegate;

- (id)initWithDelegate:(id <EngineIOTransportDelegate>) delegate {
  if (self = [super init]) {
    _delegate = delegate;
  }
  return self;
}

#pragma mark -
#pragma mark EngineIOTransport protocol

- (void)open {
  NSString *scheme = _delegate.useSecure ? @"wss" : @"ws";
  
  BOOL usePort = (_delegate.useSecure && _delegate.port != 443) ||
                 (!_delegate.useSecure && _delegate.port != 80);
  
  NSString *urlString;
  
  if (usePort) {
    urlString = [NSString stringWithFormat:kUrlPortFormat,
            scheme,
            _delegate.host,
            _delegate.port,
            _delegate.path,
            _delegate.sid];
  } else {
    urlString = [NSString stringWithFormat:kUrlFormat,
            scheme,
            _delegate.host,
            _delegate.path,
            _delegate.sid];
  }
  
  for (NSString *key in _delegate.params) {
    NSString *value = [_delegate.params objectForKey:key];
    urlString = [urlString stringByAppendingFormat:@"&%@=%@", key, value];
  }
  
  LOG(@"WebSocket connecting to URL %@", urlString);
  
  NSURL *url = [NSURL URLWithString:urlString];
  _webSocket = [[SRWebSocket alloc] initWithURL:url];
  _webSocket.delegate = self;
  [_webSocket open];
}

- (void)close {
  if (_webSocket != nil) {
    [_webSocket close];
    _webSocket.delegate = nil;
    _webSocket = nil;
  }
}

- (void)pause {
  // Unimplemented for WebSocket
}

- (void)unpause {
  // Unimplemented for WebSocket
}

- (BOOL)isReady {
  return _webSocket != nil && _webSocket.readyState == SR_OPEN;
}

- (void)sendPackets:(NSArray *)packets {
  NSAssert([self isReady], @"Cannot call sendPackets until transport is ready");
  
  for (EngineIOPacket *packet in packets) {
    NSString *encoded = [packet encoded];
    LOG(@"Sending frame to websocket: %@", encoded);
    [_webSocket send:encoded];
  }
}

#pragma mark -
#pragma mark SRWebSocketDelegate protocol

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
  // EngineIO deals in UTF8 strings, message is always a string.
  LOG(@"Received frame from websocket: %@", message);
  EngineIOPacket *packet = [EngineIOPacket packetFromString:message];
  [_delegate transport:self didReceivePacket:packet];
}

- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean {
  // See RFC6455 for the code definitions.
  LOG(@"WebSocket closed with code %d reason %@", code, reason);
  if ([_delegate respondsToSelector:@selector(transportDidClose:)]) {
    [_delegate transportDidClose:self];
  }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  LOG(@"WebSocket failed: %@", [error localizedDescription]);
  if ([_delegate respondsToSelector:@selector(transport:didFailWithError:)]) {
    [_delegate transport:self didFailWithError:error];
  }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
  LOG(@"WebSocket open");
  if ([_delegate respondsToSelector:@selector(transportDidOpen:)]) {
    [_delegate transportDidOpen:self];
  }
}

@end
