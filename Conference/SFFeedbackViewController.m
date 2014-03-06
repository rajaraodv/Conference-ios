//
//  SFFeedbackViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/5/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFFeedbackViewController.h"

@interface SFFeedbackViewController ()

@end

@implementation SFFeedbackViewController

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
    // This makes the slider call the -valueChanged: method when the user interacts with it.
    self.ratingsSlider.continuous = YES;//broadcast all the time
    [self.ratingsSlider addTarget:self
               action:@selector(valueChanged:)
     forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(UISlider*)sender
{
    NSUInteger index = (NSUInteger)(self.ratingsSlider.value + 0.5); // Round the number.
    [self.ratingsSlider setValue:index animated:NO];
    NSLog(@"index: %i", index);
    self.ratingsLabel.text = [@(index) stringValue];;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
