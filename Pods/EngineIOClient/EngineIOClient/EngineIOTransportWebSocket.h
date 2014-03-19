//
//  EngineIOTransportWebSocket.h
//  EngineIOClient
//
//  Created by Matthew Creaser on 1/29/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EngineIOTransport.h"

#import <SocketRocket/SRWebSocket.h>

/**
 *  The WebSocket transport. Uses SocketRocket to send and receive packets to the engine.io server
 *  over a websocket.
 *
 *  The websocket transport does not encode the packets into EngineIOPayload instances because 
 *  websockets already include their own framing mechanism.
 */
@interface EngineIOTransportWebSocket : NSObject<EngineIOTransport, SRWebSocketDelegate>

@end
