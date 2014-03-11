//
//  SFSponsorsCell.m
//  Conference
//
//  Created by Raja Rao DV on 3/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSponsorsCell.h"

@implementation SFSponsorsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)feedbackButton:(id)sender {
    //Is anyone listening
    if([self.delegate respondsToSelector:@selector(feedbackButtonClickedOnCell:)])
    {
        //send the delegate function with the amount entered by the user
        [self.delegate feedbackButtonClickedOnCell:self];
    }
}
@end
