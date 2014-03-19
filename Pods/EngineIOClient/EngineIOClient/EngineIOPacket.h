//
//  EngineIOPacket.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/14/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  An EngineIOPacket is the unit of messages exchanged with the engine.io server.
 */
@interface EngineIOPacket : NSObject

typedef NS_ENUM(NSInteger, PacketType) {
  OPEN,
  CLOSE,
  PING,
  PONG,
  MESSAGE,
  UPGRADE,
  NOOP
};

/**
 *  The type of the packet. All types except for MESSAGE are control packets internal to engine.io.
 */
@property (nonatomic) PacketType type;

/**
 *  The data associated with the packet, if any. This is the NSData representation of a UTF8 encoded
 *  string. May be null if there is no data associated with the packet.
 */
@property NSData *data;

/**
 *  Decodes a packet from its serialized string representation.
 *
 *  @param string The serialized form of the packet as defined in the engine.io protocol.
 *
 *  @return The deserialized packet.
 */
+ (instancetype)packetFromString:(NSString *)string;

/**
 *  Initializes a packet of the specified type with no packet data.
 *
 *  @param type The type of the packet.
 *
 *  @return The initialized packet.
 */
- (instancetype)initWithType:(PacketType)type;

/**
 *  Initializes a packet of the specified type with the specified packet data.
 *
 *  @param type The type of the packet.
 *  @param data The data in the packet.
 *
 *  @return The initialized packet.
 */
- (instancetype)initWithType:(PacketType)type data:(NSData *)data;

/**
 *  Parses the packet data as a JSON object.
 *
 *  @return The packet data parsed into a JSON object, or null if there was data or the data was
 *          not valid JSON.
 */
- (id)dataAsJSON;

/**
 *  Returns the serialized form of this single packet as defined in the engine.io protocol.
 *
 *  @return The serialized form of the packet.
 */
- (NSString *)encoded;

@end
