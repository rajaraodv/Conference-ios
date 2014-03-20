//
//  SFSessions.m
//  Conference
//
//  Created by Raja Rao DV on 3/17/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionsManager.h"
//#import "IconDownloader.h"
@implementation SFSessionsManager

+ (SFSessionsManager *)sharedInstance {
    static SFSessionsManager *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[SFSessionsManager alloc] init];
            [sharedInstance initStuff];
        }
    }
    return sharedInstance;
}

-(void) initStuff {
    //init
    self.allSessions = [[NSMutableArray alloc] init];
    self.tracks = [[NSMutableArray alloc] init];
    self.loaded = NO;
}

-(void) loadSessions {
    //init
    self.loaded = NO;

    NSString *str = @"http://localhost:3000/";
    //str = @"https://raw.github.com/rajaraodv/Conference-ios/master/test.json";
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data == nil) {
        [self showAlertWithTitle:@"No Data From Server" AndMessage:@"Looks like there is no Internet or the server is down."];
        return;
    }
    NSError *error = nil;
    NSDictionary *groupedBySessions = [NSJSONSerialization JSONObjectWithData:data options:
                                       NSJSONReadingMutableContainers                              error:&error];
    
    if (error != nil) {
        [self showAlertWithTitle:@"No Session Data" AndMessage:@"Data from server is not a valid JSON. Please Contact Admin. "];
        return;
    }
    
    NSArray *rawSessions = [groupedBySessions allValues];
    for(id rawSession in rawSessions) {
        SFSession *session = [[SFSession alloc] initWithJSONDictinoary:rawSession];
        [self.allSessions addObject: session];
    }
 
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"Start_Date_And_Time__c" ascending:YES];
    self.allSessions = [[self.allSessions sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]] mutableCopy];
    
    [self initTracks];
    [self initFavorites];
    self.loaded = YES;
}


-(void) initTracks {
    //create tracks
    self.tracks = [(NSArray *) [self.allSessions valueForKeyPath:@"Track__c"] mutableCopy];
    //get distinct/ unique values and sort it
    self.tracks = [(NSArray *)[[self.tracks valueForKeyPath:@"@distinctUnionOfObjects.self"] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    
    //Add a special None filter.
    [self.tracks addObject:@"None"];
}


-(void) initFavorites {
    //get favorites list - initialize if not found
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.favorites = [[NSMutableArray alloc] initWithArray:[self.userDefaults objectForKey:@"favorites"]];
    if(self.favorites == nil) {
        self.favorites = [[NSMutableArray alloc] init];
    }
}

-(BOOL) isCurrentSessionFavorite {
    return [self.favorites containsObject:self.currentSession.Id];
}

-(void) toggleCurrentSessionFavorite {
    NSString *sessionId = self.currentSession.Id;
    if(![self.favorites containsObject:sessionId]) {
        [self.favorites addObject: sessionId];
    } else {//unfavorite
        [self.favorites removeObject:sessionId];
        [self.userDefaults setObject:self.favorites forKey:@"favorites"];
    }
    //add to defaults and save it
    [self.userDefaults setObject:self.favorites forKey:@"favorites"];
    [self.userDefaults synchronize];
    
    self.sessionsModifiedByUser = YES;
}


- (void)showAlertWithTitle:(NSString *)title AndMessage: (NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
