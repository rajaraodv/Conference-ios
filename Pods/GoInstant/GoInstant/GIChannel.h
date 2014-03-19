//
//  GIChannel.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/16/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIRoom;
@class GIChannel;
@class GIValue;
@class GIUser;
@class GIOptions;

typedef void (^GIChannelHandler)(NSError *error);

@protocol GIChannelObserver<NSObject>
@optional
- (void)channel:(GIChannel *)channel didReceiveMessage:(id)message fromUser:(GIUser *)userId;
@end

@interface GIChannel : NSObject

+ (instancetype)channelWithName:(NSString *)name room:(GIRoom *)room;
- (instancetype)initWithName:(NSString *)name room:(GIRoom *)room;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) GIRoom *room;

- (void)sendMessage:(id)message;
- (void)sendMessage:(id)message options:(GIOptions *)options;
- (void)sendMessage:(id)message completion:(GIChannelHandler)block;
- (void)sendMessage:(id)message options:(GIOptions *)options completion:(GIChannelHandler)block;

- (void)subscribe:(id<GIChannelObserver>)observer;
- (void)unsubscribe:(id<GIChannelObserver>)observer;
- (void)unsubscribeAll;

- (BOOL)isEqualToChannel:(GIChannel *)channel;

@end
