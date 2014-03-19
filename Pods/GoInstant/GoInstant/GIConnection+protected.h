//
//  GIConnection+protected.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/20/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GIResponseHandler.h"

@class GIConnection;
@class GIRequest;

@interface GIConnection(Protected)

- (void)didAuthAsUser:(NSDictionary *)user;
- (void)didReceiveJSON:(id)json;
- (void)send:(GIRequest *)request completion:(GIResponseHandler)block;

/**
 *  Convenience method for resolving between a developer specified dispatch_queue or the main_queue if nil
 *
 *  @return the currently used dispatch_queue_t; either user defined or the main_queue
 */
- (dispatch_queue_t)resolveCompletionQueue;

/**
 *  Conevenience method for resolving the currently used dispatch_group
 *
 *  @return the currently used dispatch_group_t; either user defined or a protected instance
 */
- (dispatch_group_t)resolveCompletionGroup;


/**
 Called when the socket disconnects.
 */
- (void)didDisconnect;

/**
 Called when there is any kind of unrecoverable error
 */
- (void)didError:(NSError *)error;

@end
