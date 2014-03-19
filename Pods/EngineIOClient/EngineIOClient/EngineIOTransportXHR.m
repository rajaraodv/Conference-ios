//
//  EngineIOTransportXHR.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/13/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "EngineIOTransportXHR.h"
#import "EngineIOPayload.h"
#import "EngineIOPacket.h"
#import "EngineIOError.h"

static NSString *const kUrlFormat = @"%@://%@/%@?transport=polling&EIO=2";
static NSString *const kUrlPortFormat = @"%@://%@:%d/%@?transport=polling&EIO=2";

// The number of retry attempts if a request results in an error, before an error is returned to the
// delegate.
static const NSInteger kNumRetries = 3;

typedef NS_ENUM(NSInteger, TransportState) {
  INITIALIZED,
  OPENING,
  OPENED,
  PAUSING,
  PAUSED,
  CLOSED
};

@interface EngineIOTransportXHR (Private)
- (void) poll:(NSData *)data;
- (void) poll:(NSData *)data retryNumber:(int)retry;
- (void) pollIfNeeded;
@end

@implementation EngineIOTransportXHR {
  // The delegate that will be handling received packets.
  __weak id<EngineIOTransportDelegate> _delegate;
  
  // The URL to which to send our requests.
  NSString *_url;
  
  // The current outstanding poll requests
  NSMutableDictionary *_outstandingPolls;
  
  TransportState _state;
}

@synthesize delegate = _delegate;

#pragma mark EngineIOTransport protocol

- (id)initWithDelegate:(id<EngineIOTransportDelegate>)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _outstandingPolls = [[NSMutableDictionary alloc] init];
    _state = INITIALIZED;
  }
  
  return self;
}

- (void)open {
  LOG(@"Starting XHR transport");
  
  NSString *scheme = _delegate.useSecure ? @"https" : @"http";

  BOOL usePort = (_delegate.useSecure && _delegate.port != 443) ||
                 (!_delegate.useSecure && _delegate.port != 80);
    
  if (usePort) {
    _url = [NSString stringWithFormat:kUrlPortFormat,
            scheme,
            _delegate.host,
            _delegate.port,
            _delegate.path];
  } else {
    _url = [NSString stringWithFormat:kUrlFormat,
            scheme,
            _delegate.host,
            _delegate.path];
  }
  
  LOG(@"Polling requests will be sent to: %@", _url);
  
  _state = OPENING;
  
  [self poll:nil];
}

- (void)close {
  LOG(@"Closing XHR transport");

  // Cancel any outstanding requests.
  [_outstandingPolls enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *pollData, BOOL *stop) {
    NSURLConnection *connection = [pollData objectForKey:@"connection"];
    [connection cancel];
  }];
  [_outstandingPolls removeAllObjects];
  
  _state = CLOSED;
  
  if ([_delegate respondsToSelector:@selector(transportDidClose:)]) {
    [_delegate transportDidClose:self];
  }
}

- (BOOL)isReady {
  // The XHR polling transport is always to send ready as soon as it is opened.
  return _state == OPENED;
}

- (void)sendPackets:(NSArray *)packets {
  NSAssert([self isReady], @"Cannot call sendPackets until transport is ready");

  NSData *data = [EngineIOPayload dataFromPackets:packets];
  [self poll:data];
}

- (void)pause {
  _state = PAUSING;
}

- (void)unpause {
  _state = OPENED;
  [self pollIfNeeded];
}

#pragma mark NSURLConnectionDelegate protocol

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  LOG(@"XHR connection failed: %@", [error localizedDescription]);
  
  NSMutableDictionary *pollData = [_outstandingPolls objectForKey:connection.description];
  NSData *data = [pollData objectForKey:@"requestData"];
  
  // Remove the prior poll.
  [_outstandingPolls removeObjectForKey:connection.description];
  
  NSNumber *retries = [pollData objectForKey:@"retries"];
  if ([retries intValue] < kNumRetries - 1) {
    // Retry if we haven't already retried twice.
    [self poll:data retryNumber:[retries intValue] + 1];
  } else if ([_delegate respondsToSelector:@selector(transport:didFailWithError:)]) {
    // Retry number exceeded, fail with an error.
    NSDictionary *userInfo = @{ @"reason": @"XHR Transport failed", @"cause": error };
    [_delegate transport:self
        didFailWithError:[NSError errorWithDomain:EngineIOErrorDomain
                                             code:EngineIOErrorCouldNotSendData
                                         userInfo:userInfo]];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [[[_outstandingPolls objectForKey:connection.description] objectForKey:@"responseData"] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSMutableDictionary *pollData = [_outstandingPolls objectForKey:connection.description];
  
  NSData *responseData = [pollData objectForKey:@"responseData"];
  
  // Ignore "ok" responses
  if (![responseData isEqualToData:[@"ok" dataUsingEncoding:NSUTF8StringEncoding]]) {
    if ([_delegate respondsToSelector:@selector(transport:didReceivePacket:)]) {
      NSArray *packets = [EngineIOPayload packetsFromData:responseData];
      for (EngineIOPacket *packet in packets) {
        if (packet.type == OPEN) {
          _state = OPENED;
        }
        
        [_delegate transport:self didReceivePacket:packet];
      }
    }
  }
  
  [_outstandingPolls removeObjectForKey:connection.description];
  [self pollIfNeeded];
}

#pragma mark Private methods

- (void)poll:(NSData *)data {
  [self poll:data retryNumber:0];
}

- (void)poll:(NSData *)data retryNumber:(int)retry {
  NSMutableString *url = [[NSMutableString alloc] initWithString:_url];
  
  // Append a timestamp to the request so that we don't run into caching issues.
  NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
  double unix = timestamp * 1000;

  [url appendFormat:@"&t=%.0f", unix];
  
  if (_state == OPENING) {
    // Add the query params during the handshake.
    [_delegate.params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      [url appendFormat:@"&%@=%@", key, obj];
    }];
  } else if (_delegate.sid) {
    // Add the sesion ID if we have one.
    [url appendFormat:@"&sid=%@", _delegate.sid];
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:[_delegate pingTimeout]];
  
  if (data != nil && [data length] > 0) {
    LOG(@"Sending HTTP POST to %@", url);
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
  } else {
    LOG(@"Sending HTTP GET to %@", url);
  }
  
  [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
  
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  
  NSMutableDictionary *pollData = [[NSMutableDictionary alloc] init];
  [pollData setObject:[NSNumber numberWithInt:retry] forKey:@"retries"];
  [pollData setObject:connection forKey:@"connection"];
  [pollData setValue:data forKey:@"requestData"];
  [pollData setObject:[[NSMutableData alloc] init] forKey:@"responseData"];
  [_outstandingPolls setObject:pollData forKey:connection.description];
  
  [connection start];
}

- (void)pollIfNeeded {
  if (_state != OPENED) {
    // Once we've closed all outstanding polls then we're completely paused.
    if (_state == PAUSING && [_outstandingPolls count] == 0) {
      _state = PAUSED;
      [_delegate transportDidPause:self];
    }
    
    return;
  }
  
  BOOL __block pollNeeded = NO;
  
  if ([_outstandingPolls count] == 0) {
    pollNeeded = YES;
  } else {
    // Check to see if there is at least one outstanding poll without data.
    // Don't need to start a new poll in that case.
    pollNeeded = YES;
    for (NSString *key in _outstandingPolls) {
      NSDictionary *pollData = [_outstandingPolls objectForKey:key];
      if ([pollData objectForKey:@"data"] == nil) {
        pollNeeded = NO;
        break;
      }
    }
  }
  
  if (pollNeeded) {
    [self poll:nil];
  }
}

@end
