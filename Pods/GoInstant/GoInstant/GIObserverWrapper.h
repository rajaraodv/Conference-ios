//
//  GIObserverWrapper.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/27/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIObserverWrapper : NSObject

+ (instancetype)wrapperWithObserver:(id)observer;

@property (nonatomic, weak) id observer;

@end
