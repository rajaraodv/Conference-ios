//
//  SFFeedbackViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/5/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFThankYouViewController.h"
#import "SFAuthViewController.h"

@interface SFFeedbackViewController : UIViewController<ThankYouViewDelegate>
//@property (strong, atomic) SFSession *session;
//@property (strong, atomic) NSDictionary *sponsor;

@property (strong, atomic) NSString *type;
@property (strong, nonatomic) IBOutlet UISlider *ratingsSlider;

@property (strong, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (strong, nonatomic) IBOutlet UILabel *ratingsLabel;

- (IBAction)submitBtn:(id)sender;


@end
