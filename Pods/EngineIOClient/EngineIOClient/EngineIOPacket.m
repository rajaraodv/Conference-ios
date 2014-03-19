//
//  EngineIOPacket.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/14/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "EngineIOPacket.h"

@implementation EngineIOPacket

+ (instancetype)packetFromString:(NSString *)string {
  // Convert UTF8 character to its integer equivalent ('0' == U+0030) 
  PacketType type = [string characterAtIndex:0] - 0x30;
  NSData *data = [[string substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
  return [[self alloc] initWithType:type data:data];
}

- (instancetype)initWithType:(PacketType)type {
  return [self initWithType:type data:nil];
}

- (instancetype)initWithType:(PacketType)type data:(NSData *)data {
  if (self = [super init]) {
    _type = type;
    _data = data;
  }
  
  return self;
}

- (id)dataAsJSON {
  if (!_data) {
    return nil;
  }
  
  NSError *error = nil;
  
  id object = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
  
  if (error) {
    LOG(@"Supplied data was invalid JSON: %@", _data);
    return nil;
  }
  
  return object;
}

- (NSString *)encoded {
  NSString *encodedData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
  return [NSString stringWithFormat:@"%d%@", _type, encodedData];
}

@end
