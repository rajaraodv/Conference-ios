//
//  Backoff.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 2/5/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Backoff;

/**
 Protocol for the BackoffDelegate.
 */
@protocol BackoffDelegate

///---------------------------------
/// @name Reacting to Backoff events
///---------------------------------

/**
 The current iteration of the backoff has completed. Delegate should do do the processing they were
 waiting to do. If another iteration is needed, call the  backoff -start method again.
 */
- (void)backoffDidFinish:(Backoff *)backoff;

/**
 Called if the Backoff instance has reached it's maximum number of iterations.
 */
- (void)backoffDidReachMaxAttempts:(Backoff *)backoff;

@end

/**
 Backoff class. A backoff class can be used to fire a delegate method after an increasing delay.
 
 The Backoff delay starts at the minimumDelay, and thereafter increases according to a fibonacci 
 sequence. The amount of time between the call to -start and the delegate's -backoffDidFinish can
 be described be the number of calls to -start:
  0: minimumDelay
  1: minimumDelay
  2: 2 * minimumDelay
  3: 3 * minimumDelay
  4: 5 * minimumDelay
  5: 8 * minimumDelay
  ... etc ...
 
 Calling -reset will cancel any outstanding timers and reset the backoff to its initial state, so
 that the next call to -start will delay with the minimumDelay again.
 */
@interface Backoff : NSObject

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns a Backoff instance.
 @return The newly initialized Backoff instance.
 */
+ (instancetype)backoff;


///------------------------------
/// @name Controlling the Backoff
///------------------------------

/**
 Starts the next backoff iteration. This method will set a timer to call the delegate's
 backoffDidFinish method after the backoff delay (see class description), unless -reset is called
 in the interim.
 */
- (void)start;

/**
 Cancels any in-progress backoff iteration and resets all state. A subsequent call to -start will 
 thus result in the minimum backoff delay.
 */
- (void)reset;

/**
 The delegate to call when a backoff iteration finishes.
 */
@property (nonatomic) id<BackoffDelegate> delegate;

/**
 The minimum amount of delay, in milliseconds. Defaults to 100ms.
 */
@property (nonatomic) NSInteger minimumDelay;

/**
 The maximum number of iterations. Once this number of iterations is reached, the backoff
 will not start any timers and will call -backoffDidReachMaxAttempts for every call to -start.
 Defaults to 10 attempts.
 */
@property (nonatomic) NSInteger maximumAttempts;

@end
