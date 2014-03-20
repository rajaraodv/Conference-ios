//
//  SFSpeaker.h
//  Conference
//
//  Created by Raja Rao DV on 3/19/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFSpeaker : NSObject
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *Speaker_Bio__c;
@property (nonatomic, strong) NSString *Photo_Url__c;
@property (nonatomic, strong) NSString *Twitter__c;
@property (nonatomic, strong) NSString *Title__c;
@property (nonatomic, strong) NSString *Company__c;

-(id)initWithJSONDictinoary:(NSDictionary*)dict;
@end
