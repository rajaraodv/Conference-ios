//
//  GIContext+protected.h
//  GoInstantDriver
//
//  Created by Jeremy Wright on 2/4/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIRoom;

@interface GIContext(protected)

+ (instancetype)contextWithDictionary:(NSDictionary *)context room:(GIRoom *)room;
- (instancetype)initWithDictionary:(NSDictionary *)context room:(GIRoom *)room;

@end
