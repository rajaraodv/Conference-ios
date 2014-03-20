//
//  SFSpeakerViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/12/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSessionsManager.h"
#import "SFImageManager.h"  

@interface SFSpeakerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *speakerImageView;
@property (strong, nonatomic) IBOutlet UILabel *speakerNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *speakerTwitterLabel;
@property (strong, nonatomic) IBOutlet UILabel *speakerTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *speakerBioTextView;
@property (strong, nonatomic) IBOutlet UILabel *speakerCompany;

//@property(strong,nonatomic) UIImage *cachedSpeakerImage;//set image from prepareForSeque
- (IBAction)closeBtn:(id)sender;

@end
