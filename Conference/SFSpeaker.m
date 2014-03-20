//
//  SFSpeaker.m
//  Conference
//
//  Created by Raja Rao DV on 3/19/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSpeaker.h"

@implementation SFSpeaker
-(id)initWithJSONDictinoary:(NSDictionary*)dict {
    
    self.Name = [dict objectForKey:@"Name"];
    self.Id = [dict objectForKey:@"Id"];
    self.Speaker_Bio__c = [dict objectForKey:@"Speaker_Bio__c"];
    self.Photo_Url__c = [dict objectForKey:@"Photo_Url__c"];
    self.Twitter__c = [dict objectForKey:@"Twitter__c"];
    self.Title__c = [dict objectForKey:@"Title__c"];
    self.Company__c = [dict objectForKey:@"Company__c"];

    return self;
}
@end
