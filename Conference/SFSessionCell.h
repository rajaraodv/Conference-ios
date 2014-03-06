//
//  SFSessionCell.h
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedbackButtonDelegate <NSObject>;
-(void)feedbackButtonClickedOnCell:(id) cell;
@end

@interface SFSessionCell : UITableViewCell<UIScrollViewDelegate>
@property (nonatomic,strong) id <FeedbackButtonDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *trackLabel;
@property (strong, nonatomic) IBOutlet UITextView *sessionTitleTextView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *sessionRoomLabel;

- (IBAction)feedbackButton:(id)sender;

@end
