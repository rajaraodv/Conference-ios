//
//  GIOption.m
//  GoInstant
//
//  Created by Jeremy Wright on 2/10/14.
//  Copyright (c) 2014 Jeremy Wright. All rights reserved.
//

#import "GIOptions.h"
#import "GIOptions+protected.h"
#import "GIKey.h"

static BOOL DefaultLocal = YES;
static BOOL DefaultBubble = YES;
static BOOL DefaultOverwrite = YES;
static BOOL DefaultLastValue = NO;

static NSNumber *DefaultExpire = nil;
static GIKey *DefaultCascade = nil;

@implementation GIOptions

- (instancetype)initWithDefaults {
  if (self = [super init]) {
    _local = DefaultLocal;
  }

  return self;
}

+ (instancetype)optionsWithDefaults {
  return [[self alloc] initWithDefaults];
}

+ (instancetype)optionsWithLocal:(BOOL)local {
  GIOptions *opts = [[self alloc] initWithDefaults];

  [opts setLocal:local];
  return opts;
};

- (NSMutableDictionary *)dictionary {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  [dict setValue:[NSNumber numberWithBool:_local] forKey:@"local"];
  return dict;
}
@end

@implementation GIAddOptions

+ (instancetype)optionsWithLocal:(BOOL)local bubble:(BOOL)bubble expire:(NSNumber *)expire cascade:(GIKey *)cascade {
  GIAddOptions *opts = [super optionsWithLocal:local];

  [opts setBubble:bubble];
  [opts setExpire:expire];
  [opts setCascade:cascade];
  return opts;
}

+ (instancetype)optionsWithBubble:(BOOL)bubble {
  GIAddOptions *opts = [[self alloc] initWithDefaults];

  [opts setBubble:bubble];
  return opts;
}

+ (instancetype)optionsWithExpire:(NSNumber *)expire {
  GIAddOptions *opts = [[self alloc] initWithDefaults];

  [opts setExpire:expire];
  return opts;
}

+ (instancetype)optionsWithCascade:(GIKey *)cascade {
  GIAddOptions *opts = [[self alloc] initWithDefaults];

  [opts setCascade:cascade];
  return opts;
}

- (instancetype)initWithDefaults {
  if (self = [super initWithDefaults]) {
    _bubble = DefaultBubble;
    _expire = DefaultExpire;
    _cascade = DefaultCascade;
  }

  return self;
}

- (NSMutableDictionary *)dictionary {
  NSMutableDictionary *dict = [super dictionary];

  [dict setValue:[NSNumber numberWithBool:[self bubble]] forKey:@"bubble"];
  [dict setValue:[self expire] forKey:@"expire"];
  [dict setValue:[[self cascade] path] forKey:@"cascade"];
  return dict;
}

@end

@implementation GISetOptions

- (instancetype)initWithDefaults {
  if (self = [super initWithDefaults]) {
    _overwrite = DefaultOverwrite;
  }

  return self;
}

+ (instancetype)optionsWithOverwrite:(BOOL)overwrite {
  GISetOptions *opts = [[self alloc] initWithDefaults];

  [opts setOverwrite:overwrite];
  return opts;
}

+ (instancetype)optionsWithLocal:(BOOL)local bubble:(BOOL)bubble overwrite:(BOOL)overwrite
                         expire:(NSNumber *)expire cascade:(GIKey *)cascade {

  GISetOptions *opts = [super optionsWithLocal:local bubble:bubble expire:expire cascade:cascade];

  [opts setOverwrite:overwrite];
  return opts;
}

- (NSDictionary *)dictionary {
  NSDictionary *dict = [super dictionary];

  [dict setValue:[NSNumber numberWithBool:[self overwrite]] forKey:@"overwrite"];
  return dict;
}

@end

@implementation GIRemoveOptions

- (instancetype)initWithDefaults {
  if (self = [super initWithDefaults]) {
    _bubble = DefaultBubble;
    _lastValue = DefaultLastValue;
  }

  return self;
}

+ (instancetype)optionsWithLastValue:(BOOL)lastValue {
  GIRemoveOptions *opts = [[self alloc] initWithDefaults];

  [opts setLastValue:lastValue];
  return opts;
}

+ (instancetype)optionsWithBubble:(BOOL)bubble {
  GIRemoveOptions *opts = [[self alloc] initWithDefaults];

  [opts setBubble:bubble];
  return opts;
}

+(instancetype)optionsWithLocal:(BOOL)local bubble:(BOOL)bubble lastValue:(BOOL)lastValue {
  GIRemoveOptions *opts = [super optionsWithLocal:local];

  [opts setBubble:bubble];
  [opts setLastValue:lastValue];
  return opts;
}

- (NSDictionary *)dictionary {
  NSDictionary *dict = [super dictionary];

  [dict setValue:[NSNumber numberWithBool:[self bubble]] forKey:@"bubble"];
  [dict setValue:[NSNumber numberWithBool:[self lastValue]] forKey:@"lastValue"];
  return dict;
}

@end