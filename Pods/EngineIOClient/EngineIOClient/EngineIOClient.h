//
//  EngineIOClient.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/13/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "EngineIOTransport.h"

@class EngineIOClient;

/**
 *  EngineIODelegate protocol.
 */
@protocol EngineIODelegate<NSObject>
@optional

/**
 *  Called when the client has successfully connected to an engine.io server on the XHR transport.
 *  At this point, you may call the [EngineIOClient sendMessage] method to start sending messages to
 *  the server.
 *
 *  @param client The EngineIOClient instance that connected.
 */
- (void)engineIODidConnect:(EngineIOClient *)client;

/**
 *  Called when the client has received a message from the server.
 *
 *  @param client  The EngineIOClient instance that received the message.
 *  @param message The received message. This is the NSData representation of a UTF8 encoded string.
 */
- (void)engineIO:(EngineIOClient *)client didReceiveMessage:(NSData *)message;

/**
 *  Called when the client has disconnected from the server for any reason.
 *
 *  @param client The EngineIOClient instance that disconnected.
 *  @param error  The error that caused the disconnection, if any. May be null in non-error
 *                disconnect scenarios.
 */
- (void)engineIO:(EngineIOClient *)client didDisconnectWithError:(NSError *)error;

@end

/**
 *  An Objective C client for connecting to an engine.io server. This is a port of the JavaScript
 *  engine.io client found at https://github.com/LearnBoost/engine.io-client . 
 *
 *  @see https://github.com/LearnBoost/engine.io
 *  @see https://github.com/LearnBoost/engine.io-protocol
 */
@interface EngineIOClient : NSObject<EngineIOTransportDelegate>

///---------------------
/// @name Initialization
///---------------------

/**
 *  Initializes and returns an EngineIOClient instance.
 *
 *  @param delegate An object conforming to the EngineIODelegate protocol that may be used to
 *         respond to events from the client.
 *
 *  @return The initialized instance.
 */

+ (instancetype)clientWithDelegate:(id<EngineIODelegate>)delegate;

///-----------------------------------
/// @name Connecting and Disconnecting
///-----------------------------------

/**
 *  Attempts to connect to an engine.io server with no parameters and using the default path.
 *  If connection is successful, the delegate will receive a 
 *  [EngineIOClientDelegate engineIODidConnect] message, otherwise it will receive a
 *  [EngineIOClientDelegate engineIO:didDisconnectWithError] message.
 *
 *  @param host The host of the engine.io server.
 *  @param port The port that the engine.io server is listening on.
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port;

/**
 *  Attempts to connect to an engine.io server using the default path. If connection is successful,
 *  the delegate will receive a [EngineIOClientDelegate engineIODidConnect] message, otherwise it 
 *  will receive a [EngineIOClientDelegate engineIO:didDisconnectWithError] message.
 *
 *  @param host   The host of the engine.io server.
 *  @param port   The port that the engine.io server is listening on.
 *  @param params The query parameters to use when connecting to the engine.io server.
 */
- (void)connectToHost:(NSString *)host onPort:(NSInteger)port withParams:(NSDictionary *)params;

/**
 *  Attempts to connect to an engine.io server. If connection is successful, the delegate will
 *  receive a [EngineIOClientDelegate engineIODidConnect] message, otherwise it will receive a
 *  [EngineIOClientDelegate engineIO:didDisconnectWithError] message.
 *
 *  @param host   The host of the engine.io server.
 *  @param port   The port that the engine.io server is listening on.
 *  @param path   The path to use when connecting to the engine.io server. This may be used if your
 *                server is listening on a custom path.
 *  @param params The query parameters to use when connecting to the engine.io server.
 */
- (void)connectToHost:(NSString *)host
               onPort:(NSInteger)port
             withPath:(NSString *)path
           withParams:(NSDictionary *)params;

/**
 *  Disconnects from the engine.io server.
 */
- (void)disconnect;

///-----------------------
/// @name Sending Messages
///-----------------------

/**
 *  Sends a message to the engine.io server.
 *
 *  @param data The message to send. This is the NSData representation of a UTF8 encoded string.
 */
- (void)sendMessage:(NSData *)data;

///-----------------------------
/// @name Connection Information
///-----------------------------

/**
 *  The host of the engine.io server that the client is connecting to.
 */
@property (nonatomic, readonly) NSString *host;

/**
 *  The port on the engine.io server that the client is connecting to.
 */
@property (nonatomic, readonly) NSInteger port;

/**
 *  The path on the engine.io server that the client is connecting to. Defaults to "engine.io/"
 */
@property (nonatomic, readonly) NSString *path;

/**
 *  The session id for the current session. This is only populated after succesfully connecting to
 *  an engine.io server and received the sid in the response.
 */
@property (nonatomic, readonly) NSString *sid;

/**
 *  The query parameters used when connecting to the engine.io server.
 */
@property (nonatomic, readonly) NSDictionary *params;

/**
 *  The amount of time that can elapse without receiving a ping response from the engine.io server
 *  before treating it as a disconnect.
 */
@property (nonatomic, readonly) NSTimeInterval pingTimeout;

/**
 *  Whether or not to use secure connections (i.e. TLS) when connecting to the engine.io server.
 *  Defaults to YES. You can set this property to NO to use insecure connections if required.
 */
@property (nonatomic) BOOL useSecure;

@end
