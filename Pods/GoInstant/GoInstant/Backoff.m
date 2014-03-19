//
//  Backoff.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 2/5/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "Backoff.h"

@implementation Backoff {
  NSInteger _fibo1;
  NSInteger _fibo2;
  NSInteger _currentAttempt;
  NSTimer *_timer;
}

+ (instancetype)backoff {
  return [[self alloc] init];
}

- (instancetype)init {
  if (self = [super init]) {
    _fibo1 = _fibo2 = _currentAttempt = 1;
    _minimumDelay = 100; // Default to 100ms minimum delay
    _maximumAttempts = 10; // Default to 10 attempts
  }
  return self;
}

- (void)start {
  if (_currentAttempt > _maximumAttempts) {
    [_delegate backoffDidReachMaxAttempts:self];
    return;
  }
  
  NSTimeInterval timeToWait = (double)(_minimumDelay * _fibo2) / 1000.0; // NSTimeInterval is in sec
  LOG(@"Backoff waiting %.2f seconds before next attempt", timeToWait);
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:timeToWait
                                            target:_delegate
                                          selector:@selector(backoffDidFinish:)
                                          userInfo:nil
                                           repeats:NO];
  
  // Increase the fibonacci sequence so that we'll wait longer next time.
  if (_currentAttempt++ > 1) {
    NSInteger nextFibo = _fibo1 + _fibo2;
    _fibo1 = _fibo2;
    _fibo2 = nextFibo;
  }
}

- (void)reset {
  // Reset the counters back to the starting values;
  _fibo1 = _fibo2 = _currentAttempt = 1;
  
  // Kill the outstanding timer, if any.
  if (_timer != nil) {
    [_timer invalidate];
    _timer = nil;
  }
}

@end
