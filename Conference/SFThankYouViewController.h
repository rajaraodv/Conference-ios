//
//  SFThankYouViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/6/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThankYouViewDelegate<NSObject>;
-(void)thankYouDoneButtonClicked;
@end

@interface SFThankYouViewController : UIViewController
- (IBAction)closeBtn:(id)sender;
@property (nonatomic,strong) id <ThankYouViewDelegate> delegate;


@end
