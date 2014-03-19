//
//  EngineIOPayload.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/14/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class interface for serializing many EngineIOPacket instances into a single payload for use over
 *  the XHR transport.
 *
 *  EngineIOPayload is not used for the websocket transport since websocket have their own framing
 *  mechanism.
 *
 *  @see https://github.com/LearnBoost/engine.io-protocol
 */
@interface EngineIOPayload : NSObject

/**
 *  Deserializes one or more EngineIOPacket instances from data received from the server.
 *
 *  @param data The received data. This is the NSData representation of a UTF8 string.
 *
 *  @return An array of EngineIOPacket instances. The packets are in the same order as they appear
 *          in the supplied data.
 */
+ (NSArray *) packetsFromData:(NSData *)data;

/**
 *  Serializes one or more EngineIOPacket instances into data ready to be sent to the server.
 *
 *  @param packets The EngineIOPacket instances to serialize.
 *
 *  @return The NSData representation of the serialized packets as a UTF8 encoded string.
 */
+ (NSData *) dataFromPackets:(NSArray *)packets;

@end
