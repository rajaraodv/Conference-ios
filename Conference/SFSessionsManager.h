//
//  SFSessions.h
//  Conference
//
//  Created by Raja Rao DV on 3/17/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFSession.h"
#import "SFSpeaker.h"

@interface SFSessionsManager : NSObject

@property(strong, nonatomic) NSMutableArray *allSessions; //all sessions from server
@property(strong, nonatomic) NSMutableArray *tracks;//could be used for filtering
@property(strong, nonatomic) NSMutableArray *favorites;
@property(strong, nonatomic) NSUserDefaults *userDefaults;

//used to share sessions, speakers across views
@property(strong, nonatomic) SFSession *currentSession;//used by segues
@property(strong, nonatomic) SFSpeaker *currentSpeaker;//used by segues
@property BOOL sessionsModifiedByUser;//like favoriting a session




@property BOOL loaded;

+ (id)sharedInstance;
- (void)loadSessions;
- (BOOL) isCurrentSessionFavorite;
- (void) toggleCurrentSessionFavorite;
@end
