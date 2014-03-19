//
//  GINotification.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/27/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GINotification.h"

#import "GIConnection.h"
#import "GIRoom.h"
#import "GIKey.h"
#import "GIChannel.h"

static NSString *const kRoomNotificationFormat = @"GINOTIFY_ROOM_/%@/%@/%@";
static NSString *const kKeyNotificationFormat = @"GINOTIFY_KEY_/%@/%@/%@%@";
static NSString *const kChannelNotificationFormat = @"GINOTIFY_CHANNEL_/%@/%@/%@%@";

@implementation GINotification

+ (NSString *)nameForRoom:(GIRoom *)room {
  return [NSString stringWithFormat:kRoomNotificationFormat,
          room.connection.account,
          room.connection.app,
          room.name];
}

+ (NSString *)nameForRoomWithString:(NSString *)name connection:(GIConnection *)connection {
  return [NSString stringWithFormat:kRoomNotificationFormat,
          connection.account,
          connection.app,
          name];
}

+ (NSString *)nameForKey:(GIKey *)key {
  return [NSString stringWithFormat:kKeyNotificationFormat,
          key.room.connection.account,
          key.room.connection.app,
          key.room.name,
          key.path];
}

+ (NSString *)nameforKeyWithString:(NSString *)path
                          roomName:(NSString *)room
                        connection:(GIConnection *)connection {
  return [NSString stringWithFormat:kKeyNotificationFormat,
          connection.account,
          connection.app,
          room,
          path];
}

+ (NSString *)nameForChannel:(GIChannel *)channel {
  return [NSString stringWithFormat:kChannelNotificationFormat,
          channel.room.connection.account,
          channel.room.connection.app,
          channel.room.name,
          [NSString stringWithFormat:@"/%@", channel.name]]; // TODO : Not ideal...
}

+ (NSString *)nameforChannelWithString:(NSString *)name
                              roomName:(NSString *)room
                            connection:(GIConnection *)connection {
  return [NSString stringWithFormat:kChannelNotificationFormat,
          connection.account,
          connection.app,
          room,
          name];
}

@end
