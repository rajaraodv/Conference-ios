//
//  SFUser.m
//  Conference
//
//  Created by Raja Rao DV on 3/27/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFUser.h"

@implementation SFUser

+ (SFUser *)sharedInstance {
    static SFUser *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[SFUser alloc] init];
            [sharedInstance initStuff];
        }
    }
    return sharedInstance;
}

-(void) initStuff {
    //init
    self.rawJSONDict = [[NSDictionary alloc] init];
}

@end
