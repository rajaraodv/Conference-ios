//
//  SFUser.h
//  Conference
//
//  Created by Raja Rao DV on 3/27/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFUser : NSObject
@property (nonatomic, strong) NSDictionary *rawJSONDict;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *salesforceId;
+ (id)sharedInstance;

@end
