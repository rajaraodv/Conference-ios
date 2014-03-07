//
//  SFSessionsViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionsViewController.h"
#import "IconDownloader.h"
#import "SFFeedbackViewController.h"

@interface SFSessionsViewController ()
@property(strong, nonatomic) NSMutableDictionary *sections;
@property(strong, nonatomic) NSArray *sortedStartTimes;
@property(strong, nonatomic) NSDateFormatter *dateToStringFormatter;
@property(nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property(strong, nonatomic) NSMutableDictionary *imageCache;
@property(strong, nonatomic) UIColor *defaultCellBGColor;
@property(strong, nonatomic) GIConnection *conn;
@property(strong, nonatomic) GIChannel *channel;
@property(strong, nonatomic) NSDictionary *currentSession; //used by segue

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
    
    
    
    self.imageCache = [NSMutableDictionary dictionary];
    
    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"SessionsCustomCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"sessionCell"];
    
    NSString *str = @"http://localhost:3000/";
    // NSString *str = @"https://raw.github.com/rajaraodv/Conference-ios/master/test.json";
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data == nil) {
        [self showAlertWithTitle:@"No Data From Server" AndMessage:@"Looks like there is no Internet or the server is down."];
        return;
    }
    NSError *error = nil;
    NSDictionary *groupedBySessions = [NSJSONSerialization JSONObjectWithData:data options:
                                       NSJSONReadingMutableContainers                              error:&error];
    
    if (error != nil) {
        [self showAlertWithTitle:@"No Session Data" AndMessage:@"Data from server is not a valid JSON. Please Contact Admin. "];
        return;
    }
    //NSLog(@"Your JSON Object: %@ Or Error is: %@", groupedBySessions, error);
    
    NSArray *groupedBySessionsArray = [groupedBySessions allValues];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"Start_Date_And_Time__c" ascending:YES];
    groupedBySessionsArray = [groupedBySessionsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    
    //Used to convert Salesforce date+time string "2014-03-01T16:00:00.000+0000" to NSDate
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzzZ"];
    
    //Converts a NSDate to a readable string like: "10/10/2014 10:00PM"
    self.dateToStringFormatter = [[NSDateFormatter alloc] init];
    [self.dateToStringFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateToStringFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.sections = [NSMutableDictionary dictionary];
    for (id session in groupedBySessionsArray) {
        // Get NSDate from "2014-03-01T16:00:00.000+0000" string
        NSDate *currentStartTime = [df dateFromString:[session objectForKey:@"Start_Date_And_Time__c"]];
        
        //        // Format it to look like like: "10/10/2014 10:00PM"
        //        NSString* currentStartDateAndTime = [dateToStringFormatter stringFromDate:sessionNSDate];
        
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
    
    [self goInstant];

    
    //
    //    NSArray *myArray = [groupedBySessions allValues];
    //    NSLog(@"\n\nBefore sorting.. ");
    //    for(int i = 0; i < [myArray count]; i++) {
    //         NSLog(@"%@ Start time: %@", [myArray[i] objectForKey:@"Name"], [myArray[i] objectForKey:@"Start_Date_And_Time__c"]) ;
    //    }
    //    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"Start_Date_And_Time__c" ascending: YES];
    //
    //    NSArray *sortedArray = [myArray sortedArrayUsingDescriptors:[NSArray arrayWithObject: dateSortDescriptor]];
    //   // NSLog(@"After Sorting: %@", sortedArray);
    //    NSLog(@"\n\nAfter sorting.. ");
    //    for(int i = 0; i < [sortedArray count]; i++) {
    //        NSLog(@"%@ Start time: %@ track %@", [sortedArray[i] objectForKey:@"Name"], [sortedArray[i] objectForKey:@"Start_Date_And_Time__c"], [sortedArray[i] objectForKey:@"Track__c"] ) ;
    //    }
    //    NSLog(@"Now: %@",  [NSDate date]);
    //
    //    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzzZ"];
    //    NSDate *myDate = [df dateFromString: @"2014-03-01T16:00:00.000+0000"];
    //       NSLog(@"myDate: %@",  myDate);
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateStyle:NSDateFormatterShortStyle];
    //    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //    NSLog(@"myDate: %@",  myDate);
    //    NSLog(@"myDate: %@",[formatter stringFromDate:myDate]);
    // NSArray* values = [groupedBySessions allValues];
    
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
    NSLog(@"%@", message);
};

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - feedbackButtonDelegateHandler

- (void) feedbackButtonClickedOnCell:(id)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    self.currentSession = [sessionsAtThisStartTime objectAtIndex:indexPath.row]; // save it to property
    
    [self performSegueWithIdentifier:@"showFeedbackViewSegue" sender:self];
}

#pragma mark - segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showFeedbackViewSegue"]) {
        NSLog(@"%@", (SFFeedbackViewController*)[[segue destinationViewController] class]);

        [(SFFeedbackViewController*)[segue destinationViewController] setSession: self.currentSession];
    }
}


#pragma mark - Table view data source

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
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    NSString *timeStr = [self.dateToStringFormatter stringFromDate:currentStartTime];
    if ([sessionsAtThisStartTime count] > 1) {
        NSString *tracks = [@([sessionsAtThisStartTime count]) stringValue];
        return [NSString stringWithFormat:@"%@\t\t\t\t\t[%@ Tracks] ", timeStr, tracks];
    } else {
        return timeStr;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"sessionCell";
    SFSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SFSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //add current controller as delegate to cell's FeedbackButton control
    cell.delegate = self;
    
    //Note: store background image/color and set it back to cells in the beginning.
    //coz, imagine we had set some custom backbround image to a cell and if that cell is reused,
    // that custom background will now show up for completely different item
    if(self.defaultCellBGColor == nil) {
        self.defaultCellBGColor = cell.contentView.backgroundColor;
    }
    cell.contentView.backgroundColor =  self.defaultCellBGColor;
    
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    NSDictionary *session = [sessionsAtThisStartTime objectAtIndex:indexPath.row];
    
    cell.sessionTitleTextView.text = [session objectForKey:@"Title__c"];
    cell.trackLabel.text = [session objectForKey:@"Track__c"];
    cell.sessionRoomLabel.text = [session objectForKey:@"Location__c"];
    
    //speaker scroll view..
    //Make the cell scrollview's delegate here(as cell's init is not called when we use xib)
    cell.scrollView.delegate = cell;
    
    //hide horizontal scroller (as we have page controller)
    cell.scrollView.showsHorizontalScrollIndicator = NO;
    
   // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lunch.png"]];
    
    //cell.backgroundView = imageView;
   // cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lunch.jpg"]]; //set image for cell 0
    
    if([session objectForKey:@"Background_Image_Url__c"] != nil && [session objectForKey:@"Background_Image_Url__c"] != (id)[NSNull null]) {
        [self setBackgroundImageForCell:cell withImageUrl:[session objectForKey:@"Background_Image_Url__c"]];
    }
    
    
    //remove all subviews to avoid duplicates when cell is reused
    for (UIView *view in [cell.scrollView subviews]) {
        [view removeFromSuperview];
    }
    NSArray *speakers = [session objectForKey:@"speakers"];
    for (int i = 0; i < [speakers count]; i++) {
        NSDictionary *speaker = speakers[i];
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
        [self setImageView:speakerImageView forSpeakerImageUrl:[speaker objectForKey:@"Photo_Url__c"]];
        [button addSubview:speakerImageView];
        
        UILabel *speakerNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 5, 200, 20)];
        speakerNamelabel.text = [speaker objectForKey:@"Name"];
        [speakerNamelabel setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0f]];
        speakerNamelabel.textColor = [UIColor whiteColor];
        [button addSubview:speakerNamelabel];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, 200, 30)];
        titleLabel.text = [speaker objectForKey:@"Title__c"];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f]];
        [button addSubview:titleLabel];
    
        UILabel *twitterLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 200, 30)];
        twitterLabel.text = [speaker objectForKey:@"Twitter__c"];
        twitterLabel.textColor = [UIColor whiteColor];
        [twitterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f]];
        [button addSubview:twitterLabel];

        
        
        
        [cell.scrollView addSubview:button];
    }
    //Set the content size of our scrollview according to the total width of our speakers objects.
    cell.scrollView.contentSize = CGSizeMake(cell.scrollView.frame.size.width * [speakers count], cell.scrollView.frame.size.height);
    [cell.pageControl setNumberOfPages:[speakers count]];
    return cell;
}

// -------------------------------------------------------------------------------
//	setImageView:
// -------------------------------------------------------------------------------
- (void)setImageView:(UIImageView *)speakerImageView forSpeakerImageUrl:(NSString *)imageUrl {
    
    UIImage *image = [self.imageCache objectForKey:imageUrl];
    if (image != nil) {
        [self makeImageViewRounded:speakerImageView AndSetImage:image];
        return;
    }
    
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageUrl];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        [iconDownloader setCompletionHandler:^(UIImage *image) {
            
            
            // Display the newly loaded image
            [self.imageCache setObject:image forKey:imageUrl];
            [self makeImageViewRounded:speakerImageView AndSetImage:image];
            
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:imageUrl];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageUrl];
        
        [iconDownloader startDownloadWithURL:imageUrl AndToken:nil];
    }
}

// -------------------------------------------------------------------------------
//	setImageView:
// -------------------------------------------------------------------------------
- (void)setBackgroundImageForCell:(SFSessionCell *)cell withImageUrl:(NSString *)imageUrl {
    
    UIImage *image = [self.imageCache objectForKey:imageUrl];
    if (image != nil) {
        cell.contentView.backgroundColor = [UIColor colorWithPatternImage:image];
        
        return;
    }
    
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageUrl];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        [iconDownloader setCompletionHandler:^(UIImage *image) {
            
            
            // Display the newly loaded image
            [self.imageCache setObject:image forKey:imageUrl];
            cell.contentView.backgroundColor = [UIColor colorWithPatternImage:image];
            
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:imageUrl];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageUrl];
        
        [iconDownloader startDownloadWithURL:imageUrl AndToken:nil];
    }
}


- (void)makeImageViewRounded:(UIImageView *)speakerImageView AndSetImage:(UIImage *)image {
    
    speakerImageView.image = image;
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(speakerImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:speakerImageView.bounds
                                cornerRadius:40.0] addClip];
    // Draw your image
    [image drawInRect:speakerImageView.bounds];
    
    // Get the image, here setting the UIImageView image
    speakerImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
}


- (void)aMethod:sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    SFSessionCell * cell = (SFSessionCell *)
    [self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%d", cell.pageControl.currentPage);
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:indexPath.section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    NSDictionary *session = [sessionsAtThisStartTime objectAtIndex:indexPath.row];
    NSArray *speakers = [session objectForKey:@"speakers"];
    NSDictionary *speaker = speakers[cell.pageControl.currentPage];
    NSLog(@"speaker %@ clicked", [speaker objectForKey:@"Name"]);
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
