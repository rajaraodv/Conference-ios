//
//  SFSessionsViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSessionCell.h"
#import <GoInstant/GoInstant.h>

@interface SFSessionsViewController : UITableViewController<GIChannelObserver, FeedbackButtonDelegate, UIAlertViewDelegate>

- (IBAction)filterBtnClicked:(id)sender;
@property(strong, nonatomic) NSString* currentFilter;
@property(strong, nonatomic) NSString* previousFilter;

@end
