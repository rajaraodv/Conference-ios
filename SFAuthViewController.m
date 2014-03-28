//
//  SFAuthViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/27/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFAuthViewController.h"

@interface SFAuthViewController ()

@end

@implementation SFAuthViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [SFUser sharedInstance];
    
    [self.activityIndicator startAnimating];
    
    self.webView.delegate = self;
    // webview.scalesPageToFit = YES;
    //[[webview scrollView] setBounces:NO];
    //webview.backgroundColor = [UIColor clearColor];
    
    NSURL *url = [NSURL URLWithString:@"https://raoraja-developer-edition.na15.force.com/Conference"];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [self.webView loadRequest:requestObj];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSURL *myRequestedUrl= [webView.request mainDocumentURL];
    NSDictionary *dict = [self getURLQueryFromURL:myRequestedUrl];
    if([dict objectForKey:@"sid"]){
        NSLog(@"\n\n REQ url: %@ \n\n %@\n\n", myRequestedUrl, dict);
        [self.user setAccessToken:[dict objectForKey:@"sid"]];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    NSURL *myLoadedUrl = [webView.request mainDocumentURL];
    
    
    
    NSDictionary *dict = [self getURLQueryFromURL:myLoadedUrl];
    
    if([dict objectForKey:@"sid"]){
        [self.user setAccessToken:[dict objectForKey:@"sid"]];

        NSLog(@"\n\nLOADED url: %@ \n\n %@\n\n", myLoadedUrl, dict);

    }
    
}

-(NSDictionary *) getURLQueryFromURL:(NSURL *) url {
    NSString *queryString = [url query];
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    return queryStringDictionary;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Connection Failed", @"") message:NSLocalizedString(@"Could not load website. You must connect to a WIFI or cellular internet connection to use this feature. Other parts of this program will still work without an internet connection.", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    alert.delegate = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
