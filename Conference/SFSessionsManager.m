//
//  SFSessions.m
//  Conference
//
//  Created by Raja Rao DV on 3/17/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionsManager.h"

@implementation SFSessionsManager

+ (SFSessionsManager *)sharedInstance {
    static SFSessionsManager *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[SFSessionsManager alloc] init];
        }
    }
    return sharedInstance;
}

-(void) loadSessions {
    //init
    self.tracks = [[NSMutableArray alloc] init];
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
    
    self.allSessions = [groupedBySessions allValues];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"Start_Date_And_Time__c" ascending:YES];
    self.allSessions = [self.allSessions sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    
    
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

- (void)showAlertWithTitle:(NSString *)title AndMessage: (NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
