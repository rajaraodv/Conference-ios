//
//  SFSessions.h
//  Conference
//
//  Created by Raja Rao DV on 3/17/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFSessionsManager : NSObject

@property(strong, nonatomic) NSArray *allSessions; //all sessions from server
@property(strong, nonatomic) NSMutableArray *tracks;//could be used for filtering
@property(strong, nonatomic) NSMutableArray *favorites;
@property(strong, nonatomic) NSUserDefaults *userDefaults;
@property BOOL sessionsModifiedByUser;//like favoriting a session

@property BOOL loaded;

+ (id)sharedInstance;
- (void)loadSessions;
@end
