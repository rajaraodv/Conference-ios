//
//  SFSessionDetailsViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/18/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFSessionDetailsViewController : UIViewController<UIScrollViewDelegate>

//set session, currentSessionsFormattedTimeStr and imageCache from previous view
@property(nonatomic, strong) NSDictionary *session;
@property(nonatomic, strong) NSString *currentSessionsFormattedTimeStr;
@property (strong, nonatomic) NSMutableDictionary *imageCache;


@property (strong, nonatomic) IBOutlet UITextView *sessionTitleTextview;
@property (strong, nonatomic) IBOutlet UILabel *sessionDateAndtimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *sessionDetailsTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *speakersScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *speakersPageControl;
@property (strong, nonatomic) IBOutlet UIImageView *favoriteImageView;


@end
