//
//  SFSponsorsViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSponsorsViewController.h"
#import "SFSponsorsCell.h"
#import "IconDownloader.h"

@interface SFSponsorsViewController ()
@property(strong, nonatomic) NSMutableDictionary *sections;
@property(strong, nonatomic) NSDictionary *currentSponsor; //used by segue
@property(strong, nonatomic) NSArray *sortedLevels; // Sort to ensure expensive levels shows up at the top

// Handle image/icon downloads
@property(nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property(strong, nonatomic) NSMutableDictionary *imageCache;

@end



@implementation SFSponsorsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"SponsorsCustomCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"sponsorCell"];


    [self loadSessionDataAndReloadTable:NO];

}

-(void)loadSessionDataAndReloadTable:(BOOL) reloadTableView{
    
    NSString *str = @"http://localhost:3000/sponsors";
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data == nil) {
        [self showAlertWithTitle:@"No Data From Server" AndMessage:@"Looks like there is no Internet or the server is down."];
        return;
    }
    NSError *error = nil;
    NSMutableDictionary *groupedByLevel = [NSJSONSerialization JSONObjectWithData:data options:
                                       NSJSONReadingMutableContainers                              error:&error];
    
    if (error != nil) {
        [self showAlertWithTitle:@"No Valid Data" AndMessage:@"Data from server is not a valid JSON. Please Contact Admin. "];
        return;
    }
    

    //initialize sections
    self.sections = [NSMutableDictionary dictionary];
    
    //populate sections
    self.sections = groupedByLevel;

    // Create a sorted list of days
    NSArray *unsortedLevels = [self.sections allKeys];
    self.sortedLevels = [unsortedLevels sortedArrayUsingSelector:@selector(compare:)];
    
    //used when we need to reload view due to changes in data
    if(reloadTableView) {
        [self.tableView reloadData];
       // [self.reloadAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - feedbackButtonDelegateHandler

- (void) feedbackButtonClickedOnCell:(id)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    NSString *currentLevel = [self.sortedLevels objectAtIndex:indexPath.section];
    NSArray *sponsorsAtThisLevel = [self.sections objectForKey:currentLevel];
    self.currentSponsor = [sponsorsAtThisLevel objectAtIndex:indexPath.row];
   // NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
   // self.currentSession = [sessionsAtThisStartTime objectAtIndex:indexPath.row]; // save it to property
    
    [self performSegueWithIdentifier:@"showFeedbackViewSegue" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
     return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *currentLevel = [self.sortedLevels objectAtIndex:section];
    NSArray *sponsorsAtThisLevel = [self.sections objectForKey:currentLevel];
    return [sponsorsAtThisLevel count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *currentLevel = [self.sortedLevels objectAtIndex:section];
    NSArray *sponsorsAtThisLevel = [self.sections objectForKey:currentLevel];
    NSString *levelName = [sponsorsAtThisLevel[0] objectForKey:@"Sponsorship_Level_Name"];
    if ([sponsorsAtThisLevel count] > 1) {
        NSString *sponsorsCount = [@([sponsorsAtThisLevel count]) stringValue];
        return [NSString stringWithFormat:@"%@\t\t\t\t\t[%@ Sponsors]", levelName, sponsorsCount];
    } else {
        return levelName;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sponsorCell";
    SFSponsorsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SFSponsorsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //add current controller as delegate to cell's FeedbackButton control
    cell.delegate = self;
    
    
    //Get current sponsor from indexPath
    NSString *currentLevel = [self.sortedLevels objectAtIndex:indexPath.section];
    NSArray *sponsorsAtThisLevel = [self.sections objectForKey:currentLevel];
    NSDictionary *currentSponsor = [sponsorsAtThisLevel objectAtIndex:indexPath.row];
    
    cell.levelLabel.text = [currentSponsor objectForKey:@"Sponsorship_Level_Name"];
    cell.boothLabel.text = [currentSponsor objectForKey:@"Booth_Number__c"];
    cell.sponsorsBioTextView.text = [currentSponsor objectForKey:@"About_Text__c"];
    cell.sponsorNameLabel.text = [currentSponsor objectForKey:@"Name"];
    
    [self setImageView:cell.logoImageView forSponsorLogoUrl:[currentSponsor objectForKey:@"Image_Url__c"]];

    // Configure the cell...
    
    return cell;
}

// -------------------------------------------------------------------------------
//	setImageView:
// -------------------------------------------------------------------------------
- (void)setImageView:(UIImageView *)logoImageView forSponsorLogoUrl:(NSString *)imageUrl {
    

    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageUrl];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        [iconDownloader setCompletionHandler:^(UIImage *image) {
            
            
            // Display the newly loaded image
            [self.imageCache setObject:image forKey:imageUrl];
            logoImageView.image = image;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:imageUrl];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageUrl];
        
        [iconDownloader startDownloadWithURL:imageUrl AndToken:nil];
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
