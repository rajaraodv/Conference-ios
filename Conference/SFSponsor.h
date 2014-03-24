//
//  SFSponsor.h
//  Conference
//
//  Created by Raja Rao DV on 3/20/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFSponsor : NSObject
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *About_Text__c;
@property (nonatomic, strong) NSString *Booth_Number__c;
@property (nonatomic, strong) NSString *Give_Away_Details__c;
@property (nonatomic, strong) NSString *Image_Url__c;
@property (nonatomic, strong) NSString *Unique_Sponsor_Id__c;
@property (nonatomic, strong) NSString *Twitter__c;
@property (nonatomic, strong) NSString *Facebook_URL__c;
@property (nonatomic, strong) NSString *Sponsorship_Level_Name;
@property (nonatomic, strong) NSString *Sponsorship_Level_Internal_Sort_Number;
-(id)initWithJSONDictinoary:(NSDictionary*)dict;
@end
