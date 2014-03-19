//
//  GIObserverWrapper.m
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/27/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import "GIObserverWrapper.h"

@implementation GIObserverWrapper

+ (instancetype)wrapperWithObserver:(id)observer {
  GIObserverWrapper *wrapper = [[self alloc] init];
  wrapper.observer = observer;
  return wrapper;
}

@end
