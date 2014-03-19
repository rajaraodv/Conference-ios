//
//  GIRoom.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/16/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIConnection;
@class GIChannel;
@class GIKey;
@class GIRoom;
@class GIUser;

typedef void (^GIRoomHandler)(NSError *error);
typedef void (^GIUsersHandler)(NSError *error, NSSet *users);

@protocol GIRoomObserver<NSObject>
@optional
- (void)room:(GIRoom *)room joinedBy:(GIUser *)user;
- (void)room:(GIRoom *)room leftBy:(GIUser *)user;
@end

@interface GIRoom : NSObject

+ (instancetype)roomWithName:(NSString *)name connection:(GIConnection *)connection;
- (instancetype)initWithName:(NSString *)name connection:(GIConnection *)connection;

- (void)join;
- (void)joinWithCompletion:(GIRoomHandler)block;

- (void)leave;
- (void)leaveWithCompletion:(GIRoomHandler)block;

- (GIChannel *)channelWithName:(NSString *)name;
- (GIKey *)keyWithPath:(NSString *)path;

- (void)subscribe:(id<GIRoomObserver>)observer;
- (void)unsubscribe:(id<GIRoomObserver>)observer;
- (void)unsubscribeAll;

- (BOOL)isEqualToRoom:(GIRoom *)room;

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) GIConnection *connection;
@property(nonatomic, readonly) BOOL joined;
@property(nonatomic, readonly) NSDictionary *users;

@end
