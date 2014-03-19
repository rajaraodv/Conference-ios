//
//  GIConnection.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/17/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIConnection;
@class GIRoom;

typedef void (^GIConnectionHandler)(NSError *error, GIConnection *connection);
typedef void (^GIConnectionRoomHandler)(NSError *error, GIConnection *connection, GIRoom *room);
typedef void (^GIConnectionRoomsHandler)(NSError *error, NSArray *rooms);

@protocol GIConnectionObserver<NSObject>
@optional
- (void)connectionDidConnect:(GIConnection *)connection;
- (void)connectionDidDisconnect:(GIConnection *)connection;
- (void)connectionDidError:(NSError*)error connection:(GIConnection *)connection;
@end

@interface GIConnection : NSObject

+ (instancetype)connectionWithConnectUrl:(NSURL *)connectUrl;
- (instancetype)initWithConnectUrl:(NSURL *)connectUrl;

- (void)connect;
- (void)connectWithCompletion:(GIConnectionHandler)block;

- (void)connectAndJoinRoom:(NSString *)room jwt:(NSString *)jwt completion:(GIConnectionRoomHandler)block;
- (void)connectAndJoinRoom:(NSString *)room completion:(GIConnectionRoomHandler)block;

- (void)connectWithJwt:(NSString *)jwt;
- (void)connectWithJwt:(NSString *)jwt completion:(GIConnectionHandler)block;

- (void)disconnect;

- (GIRoom *)roomWithName:(NSString *)name;
- (void)roomsWithCompletion:(GIConnectionRoomsHandler)block;

- (void)subscribe:(id<GIConnectionObserver>)observer;
- (void)unsubscribe:(id<GIConnectionObserver>)observer;
- (void)unsubscribeAll;

@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSString *account;
@property (nonatomic, readonly) NSString *app;

/**
 *  Dispatch queue used for completion blocks. This queue is used for all GoInstant objects which run through GIConnection
 *  Including: `GIKey`, `GIChannel`, `GIRoom`
 *  If `NULL` (default), the main queue is used instead.
 */
@property (nonatomic, strong) dispatch_queue_t completionQueue;

/**
 *  Dispatch group used for completion blocks. This queue is used for all GoInstant objects which run through GIConnection
 *  Including: `GIKey`, `GIChannel`, `GIRoom`
 *  If `NULL` (default), an internal dispatch group is used instead.
 */
@property (nonatomic, strong) dispatch_group_t completionGroup;

- (BOOL)isEqualToConnection:(GIConnection *)connection;

@end
