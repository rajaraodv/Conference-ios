//
//  SFSponsorsManager.h
//  Conference
//
//  Created by Raja Rao DV on 3/20/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFSponsor.h"
@interface SFSponsorsManager : NSObject
@property(strong, nonatomic) NSMutableDictionary *allSponsors; //all sponsors from server

//used to share sessions, speakers across views
@property(strong, nonatomic) SFSponsor *currentSponsor;//used by segues

@property BOOL loaded;

+ (id)sharedInstance;

- (void)loadSponsors;

@end
