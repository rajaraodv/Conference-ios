//
//  SFAuthViewController.h
//  Conference
//
//  Created by Raja Rao DV on 3/27/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFUser.h"

@interface SFAuthViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) SFUser *user;


@end
