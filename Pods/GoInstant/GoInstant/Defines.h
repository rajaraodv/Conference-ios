//
//  Debug.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/14/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#if DEBUG
#define LOG(...) NSLog(__VA_ARGS__)
#else
#define LOG(...)
#endif