//
//  GINotification.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/27/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIRoom;
@class GIKey;
@class GIChannel;
@class GIConnection;

@interface GINotification : NSObject

+ (NSString *)nameForRoom:(GIRoom *)room;
+ (NSString *)nameForRoomWithString:(NSString *)name connection:(GIConnection *)connection;

+ (NSString *)nameForKey:(GIKey *)key;
+ (NSString *)nameforKeyWithString:(NSString *)path
                          roomName:(NSString *)room
                        connection:(GIConnection *)connection;

+ (NSString *)nameForChannel:(GIChannel *)channel;
+ (NSString *)nameforChannelWithString:(NSString *)name
                              roomName:(NSString *)room
                            connection:(GIConnection *)connection;
@end
