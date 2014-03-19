//
//  GIRoom+protected.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/27/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GIResponseHandler.h"

@class GIRoom;
@class GIRequest;

@interface GIRoom(Protected)
- (void)sendRequest:(GIRequest *)request completion:(GIResponseHandler)block;
@end
