//
//  GISocket.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/16/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EngineIOClient/EngineIOClient.h"
#import "Backoff.h"

@class GIConnection;

@interface GISocket : NSObject<EngineIODelegate, BackoffDelegate>

+ (instancetype)socketWithConnection:(GIConnection *)connection;
- (instancetype)initWithConnection:(GIConnection *)connection;

- (void)connect;
- (void)connectWithJwt:(NSString *)jwt;
- (void)disconnect;

- (void)sendJSON:(id)json;

@end
