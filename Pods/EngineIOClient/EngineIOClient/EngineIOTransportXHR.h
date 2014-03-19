//
//  EngineIOTransportXHR.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/13/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EngineIOTransport.h"

/**
 *  The XHR polling transport. This transport works by repeatedly polling the engine.io server with
 *  standard HTTP requests. The "XHR" namng comes from the JavaScript implementation of this
 *  transport.
 *
 *  The XHR transport works by sending long polling GET requests for retrieving packets, as well as
 *  POST requests for sending packets. Multiple packets may be returned in any response, and are
 *  encoded together as an EngineIOPayload.
 *
 *  The transport ensures there is always at least one outstanding GET request: if a response is
 *  received to that request, a new request is opened immediately.
 */
@interface EngineIOTransportXHR : NSObject<EngineIOTransport, NSURLConnectionDelegate>

@end
