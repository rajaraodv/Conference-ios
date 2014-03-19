//
//  GIOption.h
//  GoInstant
//
//  Created by Jeremy Wright on 2/10/14.
//  Copyright (c) 2014 Jeremy Wright. All rights reserved.
//
#import <Foundation/Foundation.h>

@class GIKey;

@interface GIOptions : NSObject
+ (instancetype)optionsWithDefaults;
+ (instancetype)optionsWithLocal:(BOOL)local;

/**
 Boolean where, if true, the event produced from this action will trigger the listeners that have opted-in to local events.
 [default: YES]
 */
@property(atomic, readwrite) BOOL local;

@end

@interface GIAddOptions : GIOptions

+ (instancetype)optionsWithLocal:(BOOL)local bubble:(BOOL)bubble expire:(NSNumber *)expire cascade:(GIKey *)cascade;
+ (instancetype)optionsWithBubble:(BOOL)bubble;
+ (instancetype)optionsWithExpire:(NSNumber *)expire;
+ (instancetype)optionsWithCascade:(GIKey *)cascade;

/**
 Boolean where, if true, the event produced from this action will bubble to all of the parent key listeners.
 [default: YES]
 */
@property(atomic, readwrite) BOOL bubble;

/**
 Time to live on the key, in milliseconds. Once the key expires, a Remove event is triggered.
 [default: nil]
 */
@property(atomic, readwrite) NSNumber *expire;

/**
 Reference to a key that will cause the set key to be removed whenever the referenced key is removed.
 [default: nil]
 */
@property(atomic, readwrite) GIKey *cascade;

@end

@interface GISetOptions : GIAddOptions

+ (instancetype)optionsWithLocal:(BOOL)local bubble:(BOOL)bubble overwrite:(BOOL)overwrite
                          expire:(NSNumber *)expire cascade:(GIKey *)cascade;
+ (instancetype)optionsWithOverwrite:(BOOL)overwrite;

/**
 Boolean where, if true, the set command will overwrite any existing value. If false, the set command will produce an error if the key already has a value.
 [default: YES]
 */
@property(atomic, readwrite) BOOL overwrite;

@end

@interface GIRemoveOptions : GIOptions

+ (instancetype)optionsWithLocal:(BOOL)local bubble:(BOOL)bubble lastValue:(BOOL)lastValue;
+ (instancetype)optionsWithBubble:(BOOL)bubble;
+ (instancetype)optionsWithLastValue:(BOOL)lastValue;

/**
 Boolean where, if true, the event produced from this action will bubble to all of the parent key listeners.
 [default: YES]
 */
@property(atomic, readwrite) BOOL bubble;

/**
 Boolean where, if true, the value of the key at the time of deletion will be returned in the callback.
 [default: YES]
 */
@property(atomic, readwrite) BOOL lastValue;

@end