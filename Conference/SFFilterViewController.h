//
//  SFFilterViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/12/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSessionsViewController.h"

@interface SFFilterViewController : UITableViewController


@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) SFSessionsViewController *sessionsViewController;

@end
