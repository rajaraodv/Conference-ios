//
//  SFSessionCell.m
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionCell.h"

@implementation SFSessionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.scrollView.delegate = self;
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) viewDidLoad {
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

@end
