//
//  EngineIOPayload.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/14/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "EngineIOPayload.h"
#import "EngineIOPacket.h"

@implementation EngineIOPayload

+ (NSArray *)packetsFromData:(NSData *)data {
  NSMutableArray *packets = [[NSMutableArray alloc] init];
  
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  NSScanner *scanner = [NSScanner scannerWithString:string];
  
  LOG(@"Decoding payload: %@", string);
  @try {
    while ([scanner isAtEnd] == NO) {    
      // The first bit is the packet length
      int packetLength;
      [scanner scanInt:&packetLength];
          
      // The next character is a colon delimiter
      [scanner scanString:@":" intoString:nil];
      
      // The packet data has the length specified in packetLength
      NSString *packetData = [string substringWithRange:NSMakeRange([scanner scanLocation], packetLength)];
      LOG(@"Extracted packet data from payload: %@", packetData);
      
      [packets addObject:[EngineIOPacket packetFromString:packetData]];
      
      // Advance the scanner past the packet data.
      [scanner setScanLocation:([scanner scanLocation] + packetLength)];
    }
  } @catch (NSException *e) {
    LOG(@"Exception: %@", e);
  }
  
  return packets;
}

+ (NSData *)dataFromPackets:(NSArray *)packets {
  // Optimization: Preprocess the packets to determine the required size of the data
  NSMutableData *data = [[NSMutableData alloc] init];
  
  for (EngineIOPacket *packet in packets) {
    NSString *preamble = [NSString stringWithFormat:@"%d:%d",
                          [packet data].length + 1, // The packet type is always one character
                          [packet type]];

    [data appendData:[preamble dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[packet data]];
  }
  
  return data;
}

@end
