//
//  SFSession.m
//  Conference
//
//  Created by Raja Rao DV on 3/19/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSession.h"

static NSDateFormatter *dateToStringFormatter;
static NSDateFormatter *salesforceDateFormatter;

@implementation SFSession

+ (NSString *)prettyfyDate:(NSDate *)date {
    return  [dateToStringFormatter stringFromDate:date];
}

//initialize static properties
+ (void)initialize {
    if (self == [SFSession class]) {
        //Used to convert Salesforce date+time string "2014-03-01T16:00:00.000+0000" to NSDate
        salesforceDateFormatter = [[NSDateFormatter alloc] init];
        [salesforceDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzzZ"];
        
        //Used to convert a NSDate to a readable string like: "Tuesday 10/10/2014 at 10:00PM"
        dateToStringFormatter = [[NSDateFormatter alloc] init];
        [dateToStringFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateToStringFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
}



-(id)initWithJSONDictinoary:(NSDictionary*)dict {
    
    self.Title__c = [dict objectForKey:@"Title__c"];
    self.Track__c = [dict objectForKey:@"Track__c"];
    self.Id = [dict objectForKey:@"Id"];
    self.Name = [dict objectForKey:@"Name"];
    self.Description__c = [dict objectForKey:@"Description__c"];
    self.Start_Date_And_Time__c = [dict objectForKey:@"Start_Date_And_Time__c"];
    self.Session_Duration__c = [dict objectForKey:@"Session_Duration__C"];
    self.End_Date_And_Time__c = [dict objectForKey:@"End_Date_And_Time__c"];
    self.Location__c = [dict objectForKey:@"Location__c"];
    self.Background_Image_Url__c = [dict objectForKey:@"Background_Image_Url__c"];
    
    self.speakers = [NSMutableArray array];
    NSArray *rawSpeakers = [dict objectForKey:@"speakers"];
    for(id rawSpeaker in rawSpeakers) {
        [self.speakers addObject:[[SFSpeaker alloc] initWithJSONDictinoary:rawSpeaker]];
    }
    
    // Get NSDate from Salesforce's "2014-03-01T16:00:00.000+0000" string
    self.Start_Date_FormattedAsNSDate = [salesforceDateFormatter dateFromString:self.Start_Date_And_Time__c];
    
     //Used to convert a NSDate to a readable string like: "Tuesday 10/10/2014 at 10:00PM"
    self.Start_Date_PrettyAsString =  [dateToStringFormatter stringFromDate:self.Start_Date_FormattedAsNSDate];
    
    return self;
}
@end
