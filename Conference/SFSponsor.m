//
//  SFSponsor.m
//  Conference
//
//  Created by Raja Rao DV on 3/20/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSponsor.h"

@implementation SFSponsor
-(id)initWithJSONDictinoary:(NSDictionary*)dict {

    self.Id = [dict objectForKey:@"Id"];
    self.Name = [dict objectForKey:@"Name"];
    self.About_Text__c = [dict objectForKey:@"About_Text__c"];
    self.Give_Away_Details__c = [dict objectForKey:@"Give_Away_Details__c"];
    self.Image_Url__c = [dict objectForKey:@"Image_Url__c"];
    self.Unique_Sponsor_Id__c = [dict objectForKey:@"Unique_Sponsor_Id__c"];
    self.Twitter__c = [dict objectForKey:@"Twitter__c"];
    self.Facebook_URL__c = [dict objectForKey:@"Facebook_URL__c"];
    self.Sponsorship_Level_Name = [dict objectForKey:@"Sponsorship_Level_Name"];
    self.Sponsorship_Level_Internal_Sort_Number = [dict objectForKey:@"Sponsorship_Level_Internal_Sort_Number"];
    
    return self;
}
@end
