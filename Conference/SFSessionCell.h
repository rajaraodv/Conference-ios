//
//  SFSessionCell.h
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFSessionCell : UITableViewCell<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *sessionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *trackLabel;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;


@end
