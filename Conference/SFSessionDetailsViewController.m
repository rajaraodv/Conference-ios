//
//  SFSessionDetailsViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/18/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionDetailsViewController.h"
#import "BackgroundLayer.h"
//#import "IconDownloader.h"
#import "SFSpeakerViewController.h"
#import "SFSessionsManager.h"
#import "SFImageManager.h"

@interface SFSessionDetailsViewController ()
@property(strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property(strong, nonatomic) NSDictionary *currentSpeaker; //used by segue

//load image manager and sessions manager
@property(strong, nonatomic) SFImageManager *imageManager;
@property (strong, nonatomic) SFSessionsManager *sessionsManager;


@end

@implementation SFSessionDetailsViewController

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
    
    //init - get singleton sessionsManager and reuse it
    self.sessionsManager = [SFSessionsManager sharedInstance];
    
    //init - load imageManager singleton and reuse it
    self.imageManager = [SFImageManager sharedInstance];
    
    SFSession *session = self.sessionsManager.currentSession;
 

   // self.sessionTitleTextview.textAlignment = NSTextAlignmentJustified;
    self.sessionDetailsTextView.textAlignment = NSTextAlignmentJustified;
    self.sessionDateAndtimeLabel.text = self.sessionsManager.currentSession.Start_Date_PrettyAsString;
    self.sessionTitleTextview.text = session.Title__c;

    self.sessionDetailsTextView.scrollEnabled = NO;
    self.sessionDetailsTextView.text = session.Description__c;
    
    self.roomNameLabel.text = session.Location__c;
    self.trackNameLabel.text = session.Track__c;
    
    CGFloat fixedWidth = self.sessionDetailsTextView.frame.size.width;

    CGSize textViewSize = [self.sessionDetailsTextView sizeThatFits:CGSizeMake(fixedWidth, FLT_MAX)];

    CGRect textViewFrame= self.sessionDetailsTextView.frame;
    textViewFrame.size = CGSizeMake(fmaxf(textViewSize.width, fixedWidth), textViewSize.height);
    [self.sessionDetailsTextView setFrame:textViewFrame];
    
//    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
//    bgLayer.frame = self.view.bounds;
//    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    //speaker scroll view..
    //Make the view scrollview's delegate here(as cell's init is not called when we use xib)
    self.speakersScrollView.delegate = self;
    
    [self addSpeakersToScrollView];
    
}

-(void) addSpeakersToScrollView {
    
    //remove all subviews to avoid duplicates when cell is reused
    for (UIView *view in [self.speakersScrollView subviews]) {
        [view removeFromSuperview];
    }
    NSArray *speakers = self.sessionsManager.currentSession.speakers;
    for (int i = 0; i < [speakers count]; i++) {
        SFSpeaker *speaker = speakers[i];
        //We'll create a button that represent each frame of the scroll view and embed everything else as its sub view.
        CGRect frame;
        frame.origin.x = self.speakersScrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size =  self.speakersScrollView.frame.size;
        
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button addTarget:self
                   action:@selector(aMethod:)
         forControlEvents:UIControlEventTouchUpInside];
        
        
        UIImageView *speakerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        speakerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageManager setImageView:speakerImageView forImageUrl:speaker.Photo_Url__c WithRadius:90.0];
       // [self.imageManager makeImageViewRounded:speakerImageView withRadius:90.0];
        [button addSubview:speakerImageView];
        
        UILabel *speakerNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 200, 20)];
        speakerNamelabel.text = speaker.Name;
        [speakerNamelabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0f]];
        speakerNamelabel.textColor = [UIColor whiteColor];
        [button addSubview:speakerNamelabel];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, 200, 30)];
        titleLabel.text = speaker.Title__c;
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f]];
        [button addSubview:titleLabel];
        
        UILabel *twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 200, 30)];
        twitterLabel.text = speaker.Twitter__c;
        twitterLabel.textColor = [UIColor whiteColor];
        [twitterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f]];
        [button addSubview:twitterLabel];
        
        
        
        
        [self.speakersScrollView addSubview:button];
    }
    //Set the content size of our scrollview according to the total width of our speakers objects.
     self.speakersScrollView.contentSize = CGSizeMake( self.speakersScrollView.frame.size.width * [speakers count],  self.speakersScrollView.frame.size.height);
    [self.speakersPageControl setNumberOfPages:[speakers count]];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.speakersPageControl.frame.size.width;
    int page = floor((self.speakersScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.speakersPageControl.currentPage = page;
}

-(void)aMethod {
    
}

//// -------------------------------------------------------------------------------
////	setImageView:
//// -------------------------------------------------------------------------------
//- (void)setImageView:(UIImageView *)speakerImageView forSpeakerImageUrl:(NSString *)imageUrl {
//    
//    UIImage *image = [self.imageCache objectForKey:imageUrl];
//    if (image != nil) {
//        [self makeImageViewRounded:speakerImageView AndSetImage:image];
//        return;
//    }
//    
//    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageUrl];
//    if (iconDownloader == nil) {
//        iconDownloader = [[IconDownloader alloc] init];
//        [iconDownloader setCompletionHandler:^(UIImage *image) {
//            
//            
//            // Display the newly loaded image
//            [self.imageCache setObject:image forKey:imageUrl];
//            [self makeImageViewRounded:speakerImageView AndSetImage:image];
//            
//            
//            // Remove the IconDownloader from the in progress list.
//            // This will result in it being deallocated.
//            [self.imageDownloadsInProgress removeObjectForKey:imageUrl];
//            
//        }];
//        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageUrl];
//        
//        [iconDownloader startDownloadWithURL:imageUrl AndToken:nil];
//    }
//}
//
//
//- (void)makeImageViewRounded:(UIImageView *)speakerImageView AndSetImage:(UIImage *)image {
//    
//    speakerImageView.image = image;
//    
//    // Begin a new image that will be the new image with the rounded corners
//    // (here with the size of an UIImageView)
//    UIGraphicsBeginImageContextWithOptions(speakerImageView.bounds.size, NO, [UIScreen mainScreen].scale);
//    
//    // Add a clip before drawing anything, in the shape of an rounded rect
//    [[UIBezierPath bezierPathWithRoundedRect:speakerImageView.bounds
//                                cornerRadius:40.0] addClip];
//    // Draw your image
//    [image drawInRect:speakerImageView.bounds];
//    
//    // Get the image, here setting the UIImageView image
//    speakerImageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    // Lets forget about that we were drawing
//    UIGraphicsEndImageContext();
//    
//}


- (void)aMethod:sender {
    //Get current speaker via cell's pagecontrol's currentPage
    NSArray *speakers = self.sessionsManager.currentSession.speakers;
    self.sessionsManager.currentSpeaker = speakers[self.speakersPageControl.currentPage];
    
    //perform segue to show speaker details
    [self performSegueWithIdentifier:@"showSpeakerViewSegue" sender:self];
}

#pragma mark - segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showSpeakerViewSegue"]) {
       // SFSpeakerViewController *svc = (SFSpeakerViewController*)[segue destinationViewController];

        
        //[svc setSpeaker:self.currentSpeaker];
       // [svc setCachedSpeakerImage:[self.imageCache objectForKey:self.sessionsManager.currentSpeaker.Photo_Url__c]];
    }
    
//    if([[segue identifier] isEqualToString:@"showFeedbackViewSegue"]) {
//        [(SFFeedbackViewController*)[segue destinationViewController] setSession: self.currentSession];
//    } else if ([[segue identifier] isEqualToString:@"showSpeakerViewSegue"]) {
//        SFSpeakerViewController *svc = (SFSpeakerViewController*)[segue destinationViewController];
//        [svc setSpeaker:self.currentSpeaker];
//        [svc setSpeakerImage:[self.imageCache objectForKey:[self.currentSpeaker objectForKey:@"Photo_Url__c"]]];
//    } else if ([[segue identifier] isEqualToString:@"showFilterViewSegue"]) {
//        SFFilterViewController *fvc = (SFFilterViewController *)[segue destinationViewController];
//        [fvc setTracks:self.sessionsManager.tracks];
//        [fvc setSessionsViewController:self];
//        [fvc setSelectedTrack: self.currentFilter];
//    } else if ([[segue identifier] isEqualToString:@"showSessionDetailsSegue"]) {
//        SFSessionDetailsViewController *sdvc = (SFSessionDetailsViewController *)[segue destinationViewController];
//        [sdvc setSession:self.currentSession];
//        [sdvc setCurrentSessionsFormattedTimeStr:self.currentSessionsFormattedTimeStr];
//        [sdvc setImageCache:self.imageCache];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
