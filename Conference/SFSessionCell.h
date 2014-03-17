//
//  SFSessionCell.h
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SessionCellDelegate <NSObject>;
-(void)feedbackButtonClickedOnCell:(id) cell;
-(void)likeButtonClickedOnCell:(id) cell forButton:(UIButton *) button;

@end


@interface SFSessionCell : UITableViewCell<UIScrollViewDelegate>
@property (nonatomic,strong) id <SessionCellDelegate> delegate;

@property (nonatomic,strong) id <SessionCellDelegate> likeButtonDelegate;

@property (strong, nonatomic) IBOutlet UILabel *trackLabel;
@property (strong, nonatomic) IBOutlet UITextView *sessionTitleTextView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *sessionRoomLabel;

- (IBAction)feedbackButton:(id)sender;

- (IBAction)likeButtonClicked:(id)sender;

//this is used to set likeButton's bgimage
@property (strong, nonatomic) IBOutlet UIButton *likeButton;

@end
