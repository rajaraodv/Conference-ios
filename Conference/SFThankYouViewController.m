//
//  SFThankYouViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/6/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFThankYouViewController.h"

@interface SFThankYouViewController ()

@end

@implementation SFThankYouViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeBtn:(id)sender {
    //Is anyone listening
    if([self.delegate respondsToSelector:@selector(thankYouDoneButtonClicked)])
    {
        //send the delegate function with the amount entered by the user
        [self.delegate thankYouDoneButtonClicked];
    }
}
@end
