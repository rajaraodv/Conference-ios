//
//  SFSponsorsCell.h
//  Conference
//
//  Created by Raja Rao DV on 3/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeedbackButtonDelegate <NSObject>;
-(void)feedbackButtonClickedOnCell:(id) cell;
@end

@interface SFSponsorsCell : UITableViewCell
@property (nonatomic,strong) id <FeedbackButtonDelegate> delegate;
- (IBAction)feedbackButton:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *boothLabel;
@property (strong, nonatomic) IBOutlet UITextView *sponsorsBioTextView;
@property (strong, nonatomic) IBOutlet UIImageView *sponsorsLogoImageView;
@property (strong, nonatomic) IBOutlet UILabel *sponsorNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@end
