//
//  EngineIOError.h
//  EngineIOClient
//
//  Created by Matthew Creaser on 1/29/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

extern NSString *const EngineIOErrorDomain;

typedef NS_ENUM(NSInteger, EngineIOError) {
  EngineIOErrorCouldNotSendData = 1,
  EngineIOErrorSocketClosed
};
