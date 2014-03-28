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
#import "SFSession.h"

@interface SFSessionDetailsViewController ()
@property(strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property(strong, nonatomic) NSDictionary *currentSpeaker; //used by segue

//load image manager and sessions manager
@property(strong, nonatomic) SFImageManager *imageManager;
@property (strong, nonatomic) SFSessionsManager *sessionsManager;

@property(strong, nonatomic) NSMutableArray *relatedSessionsArray;


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
    
    
    //init
    self.relatedSessionsArray = [[NSMutableArray alloc] init];
    self.relatedSessionsTableView.delegate = self;
    self.relatedSessionsTableView.dataSource = self;
    
    
    //init - get singleton sessionsManager and reuse it
    self.sessionsManager = [SFSessionsManager sharedInstance];
    
    //init - load imageManager singleton and reuse it
    self.imageManager = [SFImageManager sharedInstance];
    

    //add blue gradient
    [self addBlueGradientToView:self.view];
    
    //speaker scroll view..
    //Make the view scrollview's delegate here(as cell's init is not called when we use xib)
    self.speakersScrollView.delegate = self;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //add main session details like title, abstract, room etc
    [self addMainSessionDetails];
    
    //add speakers view
    [self addSpeakersToScrollView];
    
    //add related sessions table view
    [self createRelatedSessionsTable];

}

- (void)createRelatedSessionsTable {
    
    //set the label hidden until we see there is at least 1 related session
    [self.relatedSessionsLabel setHidden:YES];
    
    //make background color clear so empty cells don't show
    self.relatedSessionsTableView.backgroundColor = [UIColor clearColor];

    // Below code removes 'empty' table cells (i.e. if there are less tracks than # of cells)
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 0)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    self.relatedSessionsTableView.tableFooterView = footerView;
    
    SFSession *currentSession = self.sessionsManager.currentSession;
    NSMutableArray *allsessions =  self.sessionsManager.allSessions;
    for(int i = 0; i < allsessions.count; i++) {
        SFSession *session = allsessions[i];
        if([currentSession.Track__c isEqualToString:session.Track__c] && ![currentSession.Id isEqualToString:session.Id]) {
            [self.relatedSessionsArray addObject:session.Title__c];
        }
    }
    
    if([self.relatedSessionsArray count] > 0) {
        [self.relatedSessionsLabel setHidden:NO];
    }
    
    [self.relatedSessionsTableView reloadData];
}


- (void)addMainSessionDetails
{
    SFSession *session = self.sessionsManager.currentSession;
    
    NSString *imageName = @"like-32.png";
    if(self.sessionsManager.isCurrentSessionFavorite) {
        imageName = @"like-filled-32.png";//make it un
    }
    [self.favButtonOutlet setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    
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
        [self.imageManager setImageView:speakerImageView forImageUrl:speaker.Photo_URL__c WithRadius:90.0];
       // [self.imageManager makeImageViewRounded:speakerImageView withRadius:90.0];
        [button addSubview:speakerImageView];
        
        UILabel *speakerNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 200, 20)];
        speakerNamelabel.text = speaker.Name;
        [speakerNamelabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0f]];
        speakerNamelabel.textColor = [UIColor whiteColor];
        [button addSubview:speakerNamelabel];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, 200, 30)];
        titleLabel.text = speaker.Title;
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




#pragma mark - related sessions table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    // If You have only one(1) section, return 1, otherwise you must handle sections
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.relatedSessionsArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//deselect
    SFSession *session = [self.sessionsManager.allSessions objectAtIndex:indexPath.row];

    //set session as current session in sessionsManager
    self.sessionsManager.currentSession = session;
    
    //reload view
    [self viewDidLoad];
    [self viewWillAppear:NO];
    //scroll to the top (-70 is used to include bounce height thingy; or else, it wont scroll all the way to the top)
    [self.mainScrollView setContentOffset:CGPointMake(0, -70) animated:YES];
   


}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"relatedSessionsCell";
    
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    [cell.textLabel setTextColor:[UIColor whiteColor]];
     [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f]];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [self.relatedSessionsArray objectAtIndex:indexPath.row];
    
    
    return cell;
}


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

#pragma mark - toggle favorites
//-(void)toggleFavoritesForCell: (SFSessionCell *) cell {
// 
//
//    //toggle
//    [self.sessionsManager toggleCurrentSessionFavorite];
//    
//    
//    //change button's background
//    NSString *imageName = @"like-32.png";
//    if(self.sessionsManager.isCurrentSessionFavorite) {
//        imageName = @"like-filled-32.png";//make it un
//    }
//    [cell.likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)favButton:(id)sender {

    
    
    //toggle
    [self.sessionsManager toggleCurrentSessionFavorite];
    
    
    //change button's background
    NSString *imageName = @"like-32.png";
    if(self.sessionsManager.isCurrentSessionFavorite) {
        imageName = @"like-filled-32.png";//make it un
    }
    [self.favButtonOutlet setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

-(void) addBlueGradientToView:(UIView *) view {
    //add blue gradient
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = view.bounds;
    [view.layer insertSublayer:bgLayer atIndex:0];
}

@end
