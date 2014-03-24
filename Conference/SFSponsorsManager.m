//
//  SFSponsorsManager.m
//  Conference
//
//  Created by Raja Rao DV on 3/20/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSponsorsManager.h"

@implementation SFSponsorsManager

+ (SFSponsorsManager *)sharedInstance {
    static SFSponsorsManager *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[SFSponsorsManager alloc] init];
            [sharedInstance initStuff];
        }
    }
    return sharedInstance;
}

-(void) initStuff {
    //init
    self.allSponsors = [[NSMutableDictionary alloc] init];
    self.loaded = NO;
}


-(void) loadSponsors {
    NSString *str = @"http://localhost:3000/sponsors";
  //  str = @"https://raw.github.com/rajaraodv/Conference-ios/master/sponsorsTest.json";
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data == nil) {
        [self showAlertWithTitle:@"No Data From Server" AndMessage:@"Looks like there is no Internet or the server is down."];
        return;
    }
    NSError *error = nil;
    NSMutableDictionary *rawGroupedBySponsors = [NSJSONSerialization JSONObjectWithData:data options:
                                           NSJSONReadingMutableContainers                              error:&error];
    
    if (error != nil) {
        [self showAlertWithTitle:@"No Valid Data" AndMessage:@"Data from server is not a valid JSON. Please Contact Admin. "];
        return;
    }
    //create new grouped-by dictionary but with ACTUAL SFSponsors object
    //NSMutableDictionary *groupedBySponsors = [[NSMutableDictionary alloc] init];
    
    for(id key in rawGroupedBySponsors) {
        NSMutableArray *arrayOfSponsors = [[NSMutableArray alloc] init];
        [self.allSponsors setObject:arrayOfSponsors forKey:key];
        
        NSArray *rawSponsorsArray =  [rawGroupedBySponsors objectForKey:key];
        for(int i = 0; i < rawSponsorsArray.count; i++) {
            NSDictionary *rawSponsor = rawSponsorsArray[i];
            //create SFSponsor and add
            SFSponsor *sfSponsor = [[SFSponsor alloc] initWithJSONDictinoary:rawSponsor];
            [arrayOfSponsors addObject:sfSponsor];
        }
    }
//    NSArray *rawSponsors = [groupedBySponsors allValues];
//    for(id rawSponsor in rawSponsors) {
//        SFSponsor *sponsor = [[SFSponsor alloc] initWithJSONDictinoary:rawSponsor];
//        //[self.allSponsors addObject: sponsor];
//    }
    self.loaded = YES;
    
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
