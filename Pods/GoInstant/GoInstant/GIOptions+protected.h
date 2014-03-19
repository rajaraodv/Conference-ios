//
//  GIOption+protected.h
//  GoInstant
//
//  Created by Jeremy Wright on 2/11/14.
//  Copyright (c) 2014 Jeremy Wright. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIOptions(protected)
- (instancetype)initWithDefaults;
- (NSMutableDictionary *)dictionary;
@end