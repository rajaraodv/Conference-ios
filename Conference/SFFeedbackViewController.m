//
//  SFFeedbackViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/5/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFFeedbackViewController.h"

@interface SFFeedbackViewController ()

@property NSUInteger rating;
@property NSString *appId;
@end

@implementation SFFeedbackViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.appId = [defaults objectForKey:@"appId"];
    
    //create an app id. We use this to identify the user/app when storing feedback data.
    if(self.appId == nil) {
        self.appId = [@((long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])) stringValue];
        [defaults setObject:self.appId forKey:@"appId"];
        [defaults synchronize];
    }
    
    // This makes the slider call the -valueChanged: method when the user interacts with it.
    self.ratingsSlider.continuous = YES;//broadcast all the time
    [self.ratingsSlider addTarget:self
                           action:@selector(valueChanged:)
                 forControlEvents:UIControlEventValueChanged];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //reset slider
    [self.ratingsSlider setValue:0 animated:NO];
    self.ratingsLabel.text = @"";
    
    //reset feedback text
    self.feedbackTextView.text = @"";
    
    
}

- (void)valueChanged:(UISlider *)sender {
    self.rating = (NSUInteger) (self.ratingsSlider.value + 0.5); // Round the number.
    [self.ratingsSlider setValue:self.rating animated:NO];
    self.ratingsLabel.text = [@(self.rating) stringValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - post feedback
- (IBAction)submitBtn:(id)sender {
    [self postFeedback];
}
- (void)postFeedback {
    
    self.appId = [@((long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970])) stringValue];

    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    [jsonDict setValue:[@(self.rating) stringValue] forKey:@"Rating__c"];
    [jsonDict setValue:self.feedbackTextView.text forKey:@"Text__c"];
    [jsonDict setValue:self.appId forKey:@"Anonymous_App_Id__c"];
    if(self.session != nil) {
        [jsonDict setValue:self.session.Id forKey:@"Session__c"];
    }
    if(self.sponsor != nil) {
        [jsonDict setValue:[self.sponsor objectForKey:@"Id"] forKey:@"Sponsor__c"];
    }
 

    
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/feedback"];
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&err];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error) {
         NSDictionary *json = [NSJSONSerialization
                               JSONObjectWithData:data
                               
                               options:kNilOptions
                               error:&error];
         
         
         int statusCode = [[json objectForKey:@"statusCode"] intValue];
         if(statusCode == 200 || statusCode == 0) {
             [self performSegueWithIdentifier:@"showThankYouSegue" sender:self];
         } else {
             [self showAlertWithTitle:@"Error" AndMessage:[json objectForKey:@"messageBody"]];
         }
         
     }];
}

#pragma mark SFThankYouViewController delegate

-(void)thankYouDoneButtonClicked {
    //[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
        
       // [self.tabBarController setSelectedIndex:0];
        [self.navigationController popToRootViewControllerAnimated:NO];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tabBarController setSelectedIndex:0];
//
//        });
    }];
    
}

#pragma mark - segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showThankYouSegue"]) {
        //set ourselves as a delegate
        [(SFThankYouViewController*)[segue destinationViewController] setDelegate:self];
    }
}


- (void)showAlertWithTitle:(NSString *)title AndMessage: (NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
