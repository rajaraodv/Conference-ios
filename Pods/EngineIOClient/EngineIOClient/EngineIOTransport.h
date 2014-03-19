//
//  EngineIOTransport.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/13/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EngineIOTransport;
@class EngineIOPacket;

/**
 *  A transport delegate is responsible for receiving events from multiple transports.
 */
@protocol EngineIOTransportDelegate <NSObject>

///-----------------------------------------
/// @name Receiving packets from the server.
///-----------------------------------------

/**
 *  Called once for each packet that is received from the server. Packets are only received while
 *  the transport is open and not paused.
 *
 *  @param transport The transport that received the packet.
 *  @param packet    The received packet.
 */
- (void)transport:(id<EngineIOTransport>)transport didReceivePacket:(EngineIOPacket *)packet;

@optional

///---------------------------------
/// @name Handling transport events.
///---------------------------------

/**
 *  Called when a transport has established a connection to the server 
 *
 *  @param transport The transport that opened.
 */
- (void)transportDidOpen:(id<EngineIOTransport>)transport;

/**
 *  Called when a transport is completely paused. A paused transport will return NO when calling
 *  [EngineIOTransport isReady] and thus cannot be used to send packets, and will not receive any
 *  packets from the server.
 *
 *  @param transport The transport that was paused.
 */
- (void)transportDidPause:(id<EngineIOTransport>)transport;

/**
 *  Called when the transport closes for an expected reason.
 *
 *  @param transport The transport that closed.
 */
- (void)transportDidClose:(id<EngineIOTransport>)transport;

/**
 *  Called when the transport fails unexpectedly.
 *
 *  @param transport The transport that failed.
 *  @param error     An error that describes the cause of the failure.
 */
- (void)transport:(id<EngineIOTransport>)transport didFailWithError:(NSError *)error;

@property (nonatomic, readonly) NSString *host;
@property (nonatomic, readonly) NSInteger port;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSString *sid;
@property (nonatomic, readonly) NSDictionary *params;
@property (nonatomic, readonly) NSTimeInterval pingTimeout;
@property (nonatomic, readonly) BOOL useSecure;

@end

/**
 *  A transport instance represents one connection to the engine.io server over one of the defined
 *  engine.io transports.
 *
 *  @see https://github.com/LearnBoost/engine.io-protocol
 */
@protocol EngineIOTransport <NSObject>

/**
 *  Initializes the transport.
 *
 *  @param delegate The delegate that will handle the transport's events.
 *
 *  @return An initialized transport. The transport must still be opened before sending anything.
 */
- (id)initWithDelegate:(id <EngineIOTransportDelegate>) delegate;

/**
 *  Opens the transport. The [EngineIOTransportDelegate transportDidOpen] message will be sent once
 *  the transport has established a connection to the engine.io server.
 */
- (void)open;

/**
 *  Starts the process of pausing the transport. The [EngineIOTransportDelegate transportDidPause]
 *  message will be sent once the transport is fully paused. Packets may continue to be received
 *  on the transport until pausing is complete, but no packets may be sent.
 *
 *  No packets will be received or sent while the transport is paused.
 *
 *  Transport pausing is used during transport upgrade to ensure that no packets are lost during the
 *  upgrade.
 */
- (void)pause;

/**
 *  Resumes the transport.
 */
- (void)unpause;

/**
 *  Closes the transport. Any packets that are in flight from the server will be dropped when the
 *  transport is closed.
 */
- (void)close;

/**
 *  Checks whether the transport is ready to send and receive packets.
 *
 *  @return True if the transport is ready to send and receive packets.
 */
- (BOOL)isReady;

/**
 *  Send packets over this transport to the engine.io server. This should only be called if isReady
 *  returns YES. Attempting to send packets over a transport that is not ready will result in an
 *  assertion.
 *
 *  @param packets Array of EngineIOPacket instances to send.
 */
- (void)sendPackets:(NSArray *)packets;

///----------------------------
/// @name Transport Information
///----------------------------

/**
 *  The delegate who will receive events from this transport.
 */
@property (nonatomic, weak) id<EngineIOTransportDelegate> delegate;

@end
