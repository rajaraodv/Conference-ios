//
//  SFSession.h
//  Conference
//
//  Created by Raja Rao DV on 3/19/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFSpeaker.h"



@interface SFSession : NSObject

@property (nonatomic, strong) NSString *Title__c;
@property (nonatomic, strong) NSString *Track__c;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Description__c;
@property (nonatomic, strong) NSString *End_Date_And_Time__c;
@property (nonatomic, strong) NSString *Start_Date_And_Time__c;
@property (nonatomic, strong) NSString *Session_Duration__c;
@property (nonatomic, strong) NSString *Location__c;
@property (nonatomic, strong) NSMutableArray *speakers;
@property (nonatomic, strong) NSString *Background_Image_Url__c;
@property (nonatomic, strong) NSDate *Start_Date_FormattedAsNSDate;//using formatter
@property(nonatomic, strong) NSString *Start_Date_PrettyAsString;


-(id)initWithJSONDictinoary:(NSDictionary*)dict;
+ (NSString *)prettyfyDate:(NSDate *)date;

@end
