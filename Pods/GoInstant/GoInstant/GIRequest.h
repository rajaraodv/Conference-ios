//
//  GIRequest.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/21/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GIRequestCommand) {
  // Room Commands
  GIRequestCommandJoin,
  GIRequestCommandLeave,
  GIRequestCommandRooms,
  
  // Key Commands
  GIRequestCommandGet,
  GIRequestCommandSet,
  GIRequestCommandAdd,
  GIRequestCommandRemove,
  
  // Channel Commands
  GIRequestCommandMessage
};

@class GIRoom;
@class GIKey;

@interface GIRequest : NSObject

+ (instancetype)requestWithCommand:(GIRequestCommand)command options:(NSDictionary *)options;
- (instancetype)initWithCommand:(GIRequestCommand)command options:(NSDictionary *)options;

- (NSMutableDictionary *)dictionary;

@property (nonatomic) NSString *command;
@property (nonatomic) NSString *room;
@property (nonatomic) NSString *key;
@property (nonatomic) id value;
@property (nonatomic) NSDictionary *options;
@property (nonatomic) NSInteger callbackId;

@end
