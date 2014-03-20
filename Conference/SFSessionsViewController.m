//
//  SFSessionsViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionsViewController.h"
//#import "IconDownloader.h"
#import "SFFeedbackViewController.h"
#import "SFSpeakerViewController.h"
#import "SFFilterViewController.h"
#import "SFSessionDetailsViewController.h"
#import "SFSession.h"
#import "SFSpeaker.h"
#import "SFImageManager.h"


@interface SFSessionsViewController ()
@property(strong, nonatomic) NSMutableDictionary *sections;
@property(strong, nonatomic) NSArray *sortedStartTimes;
//@property(strong, nonatomic) NSDateFormatter *dateToStringFormatter;
//@property(strong, nonatomic) NSDateFormatter *salesforceDateFormatter;
//@property(strong, nonatomic) NSMutableDictionary *imageDownloadsInProgress;
//@property(strong, nonatomic) NSMutableDictionary *imageCache;
@property(strong, nonatomic) UIColor *defaultCellBGColor;
@property(strong, nonatomic) GIConnection *conn;
@property(strong, nonatomic) GIChannel *channel;
//@property(strong, nonatomic) NSDictionary *currentSession; //used by feedback segue
@property(strong, nonatomic) UIAlertView *reloadAlert;
//@property(strong, nonatomic) NSDictionary *currentSpeaker; //used by speaker segue
@property(strong, nonatomic) SFSessionsManager *sessionsManager;
@property(strong, nonatomic)  NSString *currentSessionsFormattedTimeStr;//used by session details segue
//@property BOOL useCurrentDataButReloadTable;
@property(strong, nonatomic) SFImageManager *imageManager;
@end

@implementation SFSessionsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    //load sessionsManager singleton
    self.sessionsManager = [SFSessionsManager sharedInstance];
    if(!self.sessionsManager.loaded) {
        [self.sessionsManager loadSessions];
    }
    
    //load imageManager singleton
    self.imageManager = [SFImageManager sharedInstance];
    
//    self.imageCache = [NSMutableDictionary dictionary];
//    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.sessionsManager.sessionsModifiedByUser = NO;

    
//    //Used to convert Salesforce date+time string "2014-03-01T16:00:00.000+0000" to NSDate
//    self.salesforceDateFormatter = [[NSDateFormatter alloc] init];
//    [self.salesforceDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzzZ"];
//    
//    //Converts a NSDate to a readable string like: "10/10/2014 10:00PM"
//    self.dateToStringFormatter = [[NSDateFormatter alloc] init];
//    [self.dateToStringFormatter setDateStyle:NSDateFormatterLongStyle];
//    [self.dateToStringFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"SessionsCustomCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"sessionCell"];

    [self createSectionsAndreloadTableView:NO]; //create sections but dont reload as it will be automatically done
    
    //initialize goInstant
    [self goInstant];
    
   
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:YES];

   
    
    [self manageFilters];
   
}

-(void)viewDidAppear:(BOOL)animated {
    //Note: Do this in view_did_appear. coz viewWillAppear wont have selectedIndex set yet.
    //reload just table cells(used to ensure favorite and not favorite sessions lists are updated
    // every time user toggles b/w two tabs)
    if(self.sessionsManager.sessionsModifiedByUser) {
        [self createSectionsAndreloadTableView:YES];
    }
}

-(void) manageFilters {
    
    if(self.currentFilter != nil && ![self.previousFilter isEqualToString:self.currentFilter]) {
        
        self.previousFilter = self.currentFilter;
        [self createSectionsAndreloadTableView:YES];
        
        
    }
    //change title color
    if(self.currentFilter == nil || [self.currentFilter isEqualToString:@"None"]) {
        self.title = @"Sessions";
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    } else {
        self.title = self.currentFilter;
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor redColor]};
    }
}

-(void)handleTapOnTextView:(UIGestureRecognizer *)recognizer {
    // Get IndexPath based on x,y coordinates
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];

    
    //Get list of speakers for the current session
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    NSDictionary *session = [sessionsAtThisStartTime objectAtIndex:indexPath.row];
    NSLog(@"%@", session);
}


- (void)createSectionsAndreloadTableView:(BOOL)reloadTableView {
    NSLog(@"**********************%lu", (unsigned long)self.navigationController.tabBarController.selectedIndex);

    self.sections = [NSMutableDictionary dictionary];
    for (SFSession *session in self.sessionsManager.allSessions) {
        //in sessions tab..
        if(self.navigationController.tabBarController.selectedIndex == 0) {
            //ignore filter for None and nil.
            if(self.currentFilter != nil && ![self.currentFilter isEqualToString:@"None"]) {
                BOOL filterMatched = [session.Track__c isEqualToString:self.currentFilter];
                if(!filterMatched) {//dont add session that dont match filter
                    continue;
                }
            }
            
        } else if(self.navigationController.tabBarController.selectedIndex == 1) {//in favorites tab..
            if(![self.sessionsManager.favorites containsObject:session.Id]) {
                //skip if not in favorites list
                continue;
            }
        }
        // Get "NSDate" from "2014-03-01T16:00:00.000+0000" string
        NSDate *currentStartTime = session.Start_Date_FormattedAsNSDate;
        
 
        
        // See if we have sessions for current start date and time
        NSMutableArray *sessionsAtThisTime = [self.sections objectForKey:currentStartTime];
        if (sessionsAtThisTime == nil) {
            sessionsAtThisTime = [NSMutableArray array];
            
            // Add the session to the list for this day
            [sessionsAtThisTime addObject:session];
            
            // Add sessions array to the section w/ currentStartDateAndTime as key
            [self.sections setObject:sessionsAtThisTime forKey:currentStartTime];
        } else {
            // Add the session to the list for this day
            [sessionsAtThisTime addObject:session];
        }
    }
    
    
    
    // Create a sorted list of days
    NSArray *unsortedDays = [self.sections allKeys];
    self.sortedStartTimes = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    
    if(reloadTableView) {
        [self.tableView reloadData];
        [self.reloadAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}



- (void)goInstant{
     self.conn = [GIConnection connectionWithConnectUrl:[NSURL URLWithString:@"https://goinstant.net/6d90f902767a/Conference"]];
   
    GIConnectionRoomHandler testConnRoomBlock = ^(NSError *error, GIConnection *connection, GIRoom *room) {
        //subscribe to channel
        self.channel =  [room channelWithName:@"conferenceChannel"];
        [self.channel subscribe:self];
    };
    
    //join room1
    [self.conn connectAndJoinRoom:@"room1" completion:testConnRoomBlock];
}

// wait for messages
- (void)channel:(GIChannel *)channel didReceiveMessage:(id)message fromUser:(GIUser *)userId {
    //[self showAlertWithTitle:@"Updates Available" AndMessage:[message description]];
    self.reloadAlert = [[UIAlertView alloc]initWithTitle:@"Updates Available" message:@"Would you like to reload data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [self.reloadAlert show];
};



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Code for OK button
    }
    if (buttonIndex == 1)
    {
        //[self loadSessionDataAndReloadTable:YES];
        [self.sessionsManager loadSessions];
        [self createSectionsAndreloadTableView:YES];

        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - feedbackButtonClickedOnCell and likeButtonClickedOnCell (SessionCellDelegate)

- (void) feedbackButtonClickedOnCell:(id)cell {
   [self setSessionAsCurrentForCell:cell]; // set current cell's session as current
    [self performSegueWithIdentifier:@"showFeedbackViewSegue" sender:self];
}


- (void) likeButtonClickedOnCell:(id)cell forButton:(UIButton *)button {
    [self toggleFavoritesForCell:(SFSessionCell *) cell];
}

//show session details when textViewButtonClickedOnCell
- (void) textViewButtonClickedOnCell:(id)cell forButton:(UIButton *)button {
    // set current cell's session as current
    [self setSessionAsCurrentForCell:cell];
    
    
//    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
//    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
//    self.currentSessionsFormattedTimeStr = [self.dateToStringFormatter stringFromDate:currentStartTime];

    [self performSegueWithIdentifier:@"showSessionDetailsSegue" sender:self];
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}



-(void)setSessionAsCurrentForCell:(id) cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    self.sessionsManager.currentSession =  [sessionsAtThisStartTime objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    return [sessionsAtThisStartTime count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:section];
    NSString *timeStr = [SFSession prettyfyDate:currentStartTime];
    //NSString *timeStr = [self.dateToStringFormatter stringFromDate:currentStartTime];
    
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    if ([sessionsAtThisStartTime count] > 1) {
        NSString *tracks = [@([sessionsAtThisStartTime count]) stringValue];
        return [NSString stringWithFormat:@" %@\t\t\t[%@ Tracks] ", timeStr, tracks];
    } else {
        return [NSString stringWithFormat:@" %@", timeStr];
    }
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
// 
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    static NSString *CellIdentifier = @"sessionCell";
    SFSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SFSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //add current controller as delegate to cell's FeedbackButton and LikeButton control
    cell.delegate = self;//feedback
    cell.likeButtonDelegate = self; //like
    cell.textViewButtonDelegate = self;//click on textview
    
    
    //dont highlight selection
  //  [cell.contentView setUserInteractionEnabled:NO];
   // [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //Note: store background image/color and set it back to cells in the beginning.
    //coz, imagine we had set some custom backbround image to a cell and if that cell is reused,
    // that custom background will now show up for completely different item
    if(self.defaultCellBGColor == nil) {
        self.defaultCellBGColor = cell.contentView.backgroundColor;
    }
    cell.contentView.backgroundColor =  self.defaultCellBGColor;
    
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    SFSession *session = [sessionsAtThisStartTime objectAtIndex:indexPath.row];
    
    NSString *sessionId = session.Id;
    
    //reset like image before setting it filled (coz cells are reused!)
    [cell.likeButton setImage:[UIImage imageNamed:@"like-32.png"] forState:UIControlStateNormal];
    if([self.sessionsManager.favorites containsObject:sessionId]) {//set filled if found
        [cell.likeButton setImage:[UIImage imageNamed:@"like-filled-32.png"] forState:UIControlStateNormal];
    }
    cell.sessionTitleTextView.text = session.Title__c;
    cell.trackLabel.text = session.Track__c;
    cell.sessionRoomLabel.text = session.Location__c;
    
    //speaker scroll view..
    //Make the cell scrollview's delegate here(as cell's init is not called when we use xib)
    cell.scrollView.delegate = cell;
    
    //hide horizontal scroller (as we have page controller)
    cell.scrollView.showsHorizontalScrollIndicator = NO;
    
    
    if(session.Background_Image_Url__c != nil && session.Background_Image_Url__c != (id)[NSNull null]) {
        //[self setBackgroundImageForView:cell.contentView withImageUrl:session.Background_Image_Url__c];
        [self.imageManager setBackgroundImageForView:cell.contentView withImageUrl:session.Background_Image_Url__c];
    }
    
    
    //remove all subviews to avoid duplicates when cell is reused
    for (UIView *view in [cell.scrollView subviews]) {
        [view removeFromSuperview];
    }
    NSArray *speakers = session.speakers;
    for (int i = 0; i < [speakers count]; i++) {
        SFSpeaker *speaker = speakers[i];
        //We'll create a button that represent each frame of the scroll view and embed everything else as its sub view.
        CGRect frame;
        frame.origin.x = cell.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = cell.scrollView.frame.size;
        
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button addTarget:self
                   action:@selector(aMethod:)
         forControlEvents:UIControlEventTouchUpInside];
        
        
        UIImageView *speakerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        speakerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageManager setImageView:speakerImageView forImageUrl:speaker.Photo_Url__c WithRadius:40.0];
        //[self.imageManager makeImageViewRounded:speakerImageView withRadius:40.0];
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

        
        
        
        [cell.scrollView addSubview:button];
    }
    //Set the content size of our scrollview according to the total width of our speakers objects.
    cell.scrollView.contentSize = CGSizeMake(cell.scrollView.frame.size.width * [speakers count], cell.scrollView.frame.size.height);
    [cell.pageControl setNumberOfPages:[speakers count]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}
//
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
//// -------------------------------------------------------------------------------
////	setImageView:withImageUrl
//// -------------------------------------------------------------------------------
//- (void)setBackgroundImageForView:(UIView *)view withImageUrl:(NSString *)imageUrl {
//    
//    UIImage *image = [self.imageCache objectForKey:imageUrl];
//    if (image != nil) {
//        view.backgroundColor = [UIColor colorWithPatternImage:image];
//        
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
//            view.backgroundColor = [UIColor colorWithPatternImage:image];
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
    // Get IndexPath based on x,y coordinates
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    //Get list of speakers for the current session
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    SFSession *session = [sessionsAtThisStartTime objectAtIndex:indexPath.row];
    NSArray *speakers = session.speakers;
    
    //get cell for the indexPath
    SFSessionCell * cell = (SFSessionCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    //Get current speaker via cell's pagecontrol's currentPage
    self.sessionsManager.currentSpeaker = speakers[cell.pageControl.currentPage];

    //perform segue to show speaker details
    [self performSegueWithIdentifier:@"showSpeakerViewSegue" sender:self];
    
    
}

#pragma mark - segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showFeedbackViewSegue"]) {
       [(SFFeedbackViewController*)[segue destinationViewController] setSession: self.sessionsManager.currentSession];
    } else if ([[segue identifier] isEqualToString:@"showSpeakerViewSegue"]) {
       // SFSpeakerViewController *svc = (SFSpeakerViewController*)[segue destinationViewController];
       // [svc setSpeaker:self.currentSpeaker];
       // [svc setCachedSpeakerImage:[self.imageCache objectForKey:self.sessionsManager.currentSpeaker.Photo_Url__c]];
    } else if ([[segue identifier] isEqualToString:@"showFilterViewSegue"]) {
        SFFilterViewController *fvc = (SFFilterViewController *)[segue destinationViewController];
        [fvc setTracks:self.sessionsManager.tracks];
        [fvc setSessionsViewController:self];
        [fvc setSelectedTrack: self.currentFilter];
    } else if ([[segue identifier] isEqualToString:@"showSessionDetailsSegue"]) {
       // SFSessionDetailsViewController *sdvc = (SFSessionDetailsViewController *)[segue destinationViewController];
        //[sdvc setSession:self.sessionsManager.currentSession];
      //  [sdvc setCurrentSessionsFormattedTimeStr:self.currentSessionsFormattedTimeStr];
      //  [sdvc setImageCache:self.imageCache];
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

#pragma mark - filter button related
- (IBAction)filterBtnClicked:(id)sender {
    [self performSegueWithIdentifier:@"showFilterViewSegue" sender:self];
}

#pragma mark - toggle favorites
-(void)toggleFavoritesForCell: (SFSessionCell *) cell {
    
    // set current cell's session as current
    [self setSessionAsCurrentForCell:cell];

 
    //toggle
    [self.sessionsManager toggleCurrentSessionFavorite];
    
    
    //change button's background
    NSString *imageName = @"like-32.png";
    if(self.sessionsManager.isCurrentSessionFavorite) {
        imageName = @"like-filled-32.png";//make it un
    }
    [cell.likeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
}

@end
