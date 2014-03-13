//
//  SFSpeakerViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/12/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSpeakerViewController.h"

@interface SFSpeakerViewController ()

@end

@implementation SFSpeakerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.speakerBioTextView.backgroundColor = [UIColor clearColor];
    self.speakerBioTextView.textAlignment = NSTextAlignmentJustified;
    self.speakerBioTextView.text = [self.speaker objectForKey:@"Speaker_Bio__c"];
    
   // [self.speakerBioTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0f]];

    //self.speakerImageView.image = self.speakerImage;
    [self makeImageViewRounded:self.speakerImageView AndSetImage:self.speakerImage];
    self.speakerTitleLabel.text = [self.speaker objectForKey:@"Title__c"];
    self.speakerNameLabel.text = [self.speaker objectForKey:@"Name"];
    self.speakerTwitterLabel.text = [self.speaker objectForKey:@"Twitter__c"];
    self.speakerCompany.text = [self.speaker objectForKey:@"Company__c"];

	// Do any additional setup after loading the view.
}

- (void)makeImageViewRounded:(UIImageView *)speakerImageView AndSetImage:(UIImage *)image {
    
    speakerImageView.image = image;
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(speakerImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:speakerImageView.bounds
                                cornerRadius:90] addClip];
    // Draw your image
    [image drawInRect:speakerImageView.bounds];
    
    // Get the image, here setting the UIImageView image
    speakerImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
