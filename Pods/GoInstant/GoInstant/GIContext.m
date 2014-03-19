//
//  GIContext.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/20/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIContext.h"
#import "GIKey.h"
#import "GIRoom.h"
#import "GiUser.h"

@interface GIContext(protected)
- (GIKey *)resolveKey:(NSString *)keyName room:(GIRoom *)room;
@end

@interface GIContext(private)
+ (GIContextCommand)enumForCommandString:(NSString *)command;
@end

@implementation GIContext

+ (instancetype)contextWithDictionary:(NSDictionary *)context room:(GIRoom *)room {
  return [[self alloc] initWithDictionary:context room:room];
};

- (instancetype)initWithDictionary:(NSDictionary *)context room:(GIRoom *)room {
  if (self = [super init]) {
    _room = room;
    _command = [GIContext enumForCommandString:[context objectForKey:@"command"]];
    _userId = [context objectForKey:@"userId"];
    _user = [_room.users objectForKey:_userId];
    _key = [self resolveKey:[context objectForKey:@"key"] room:room];
    _value = [context objectForKey:@"value"];
  }

  return self;
};

#pragma mark -
#pragma mark Protected Interface

- (GIKey *)resolveKey:(NSString *)keyName room:(GIRoom *)room {
  // Saves us from wasting an allocation on a key that should just be nil
  if (keyName == nil) {
    return nil;
  }

  return [GIKey keyWithPath:keyName room:room];
};

#pragma mark -
#pragma mark Private Interface

+ (GIContextCommand)enumForCommandString:(NSString *)command {
  if ([command isEqualToString:@"GET"]) {
    return GIContextCommandGet;
  } else if ([command isEqualToString:@"SET"]) {
    return GIContextCommandSet;
  } else if ([command isEqualToString:@"ADD"]) {
    return GIContextCommandAdd;
  } else if ([command isEqualToString:@"REMOVE"]) {
    return GIContextCommandRemove;
  }

  return GIContextCommandUnknown;
};

@end

@implementation GISetContext

- (instancetype)initWithDictionary:(NSDictionary *)context room:(GIRoom *)room {
  if (self = [super initWithDictionary:context room:room]) {
    _cascade = [context valueForKey:@"cascade"];
  }

  return self;
}

@end

@implementation GIGetContext

- (instancetype)initWithDictionary:(NSDictionary *)context room:(GIRoom *)room {
  if (self = [super initWithDictionary:context room:room]) {
    _overwritten = [[context objectForKey:@"overwritten"] boolValue];
  }

  return self;
}

@end

@implementation GIAddContext

- (instancetype)initWithDictionary:(NSDictionary *)context room:(GIRoom *)room {
  if (self = [super initWithDictionary:context room:room]) {
    _addedKey = [self resolveKey:[context objectForKey:@"addedKey"] room:room];
  }

  return self;
};

@end

@implementation GIRemoveContext

- (instancetype)initWithDictionary:(NSDictionary *)context room:(GIRoom *)room {
  if (self = [super initWithDictionary:context room:room]) {
    _cascaded = [[context objectForKey:@"cascaded"] boolValue];
    _expired = [[context objectForKey:@"expired"] boolValue];
  }

  return self;
};

@end