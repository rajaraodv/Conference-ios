//
//  SFSessionDetailsViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/18/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSession.h"
#import "SFSpeaker.h"


@interface SFSessionDetailsViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource, UITableViewDelegate>

//set session, currentSessionsFormattedTimeStr and imageCache from previous view
//@property(nonatomic, strong) SFSession *session;
//@property(nonatomic, strong) NSString *currentSessionsFormattedTimeStr;
//@property (strong, nonatomic) NSMutableDictionary *imageCache;


@property (strong, nonatomic) IBOutlet UITextView *sessionTitleTextview;
@property (strong, nonatomic) IBOutlet UILabel *sessionDateAndtimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *sessionDetailsTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *speakersScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *speakersPageControl;
- (IBAction)favButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *favButtonOutlet;

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) IBOutlet UITableView *relatedSessionsTableView;

@property (strong, nonatomic) IBOutlet UILabel *relatedSessionsLabel;



@end
