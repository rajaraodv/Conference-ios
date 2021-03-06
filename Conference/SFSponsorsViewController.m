//
//  SFSponsorsViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/10/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSponsorsViewController.h"
#import "SFSponsorsCell.h"
//#import "IconDownloader.h"
#import <QuartzCore/QuartzCore.h>
#import "SFFeedbackViewController.h"
#import "GM_FSHighlightAnimationAdditions.h"
#import "SFImageManager.h"


@interface SFSponsorsViewController ()
@property(strong, nonatomic) NSMutableDictionary *sections;
@property(strong, nonatomic) NSDictionary *currentSponsor; //used by segue
@property(strong, nonatomic) NSArray *sortedLevels; // Sort to ensure expensive levels shows up at the top

// Handle image/icon downloads
@property(nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
//@property(strong, nonatomic) NSMutableDictionary *imageCache;

@property(strong, nonatomic) SFSponsorsManager *sponsorsManager;

@property(strong, nonatomic) UIColor *headerBGColor;

@property(strong, nonatomic) SFImageManager *imageManager;

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
    
    //init and load imageManager singleton
    self.imageManager = [SFImageManager sharedInstance];
    
    //register main table view's xib file
    [self.tableView registerNib:[UINib nibWithNibName:@"SponsorsCustomCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"sponsorCell"];

    //init - get singleton sessionsManager and reuse it
    self.sponsorsManager = [SFSponsorsManager sharedInstance];

    [self loadSessionDataAndReloadTable:NO];
    
    

}

-(void)loadSessionDataAndReloadTable:(BOOL) reloadTableView{
    if(![self.sponsorsManager loaded]) {
        [self.sponsorsManager loadSponsors];
    }

    //initialize sections
    self.sections = [NSMutableDictionary dictionary];
    
    //populate sections
    self.sections = self.sponsorsManager.allSponsors;

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

#pragma mark - feedbackButtonDelegateHandler (SessionCustomCell)

- (void) feedbackButtonClickedOnCell:(id)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell];
    NSString *currentLevel = [self.sortedLevels objectAtIndex:indexPath.section];
    NSArray *sponsorsAtThisLevel = [self.sections objectForKey:currentLevel];
    self.sponsorsManager.currentSponsor = [sponsorsAtThisLevel objectAtIndex:indexPath.row];
   // NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
   // self.currentSession = [sessionsAtThisStartTime objectAtIndex:indexPath.row]; // save it to property
    
    [self performSegueWithIdentifier:@"showFeedbackViewSegue2" sender:self];
}


#pragma mark - likeButtonDelegateHandler (SessionCustomCell)



#pragma mark - segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showFeedbackViewSegue2"]) {
        [(SFFeedbackViewController*)[segue destinationViewController] setType:@"Sponsor"];
    }
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
    SFSponsor *currentSponsor = sponsorsAtThisLevel[0];
    NSString *levelName = currentSponsor.Sponsorship_Level_Name;
    if ([sponsorsAtThisLevel count] > 1) {
        NSString *sponsorsCount = [@([sponsorsAtThisLevel count]) stringValue];
        return [NSString stringWithFormat:@"   %@\t\t\t\t\t\t[%@ Sponsors]", levelName, sponsorsCount];
    } else {
        return [NSString stringWithFormat:@"   %@", levelName];
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
    
    //dont highlight selection
   [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    

    //Get current sponsor from indexPath
    NSString *currentLevel = [self.sortedLevels objectAtIndex:indexPath.section];
    NSArray *sponsorsAtThisLevel = [self.sections objectForKey:currentLevel];
    SFSponsor *currentSponsor = [sponsorsAtThisLevel objectAtIndex:indexPath.row];
    
    //cell.levelLabel.text = [currentSponsor objectForKey:@"Sponsorship_Level_Name"];
    cell.boothLabel.text = currentSponsor.Booth_Number__c;
    cell.sponsorNameLabel.text = currentSponsor.Name;
    cell.giveAwayTextView.text = currentSponsor.Give_Away_Details__c;
   
    
    cell.logoImageView.layer.cornerRadius = 20.0;
    cell.logoImageView.clipsToBounds = YES;
    cell.logoImageView.backgroundColor = [UIColor whiteColor];
    
    if(self.headerBGColor == nil)
        self.headerBGColor = cell.levelLabel.backgroundColor;
    
    //[self setImageView:cell.logoImageView forSponsorLogoUrl:[currentSponsor objectForKey:@"Image_Url__c"]];
    [self.imageManager setImageView:cell.logoImageView forImageUrl:currentSponsor.Image_Url__c WithRadius:0.0];
   
  //  [cell.levelLabel GM_setAnimationLTRWithText:[currentSponsor objectForKey:@"Sponsorship_Level_Name"] andWithDuration:2.0f andWithRepeatCount:0];
   

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //view.tintColor = [UIColor colorWithRed:(47/255.0) green:(80/255.0) blue:(173/255.0) alpha:1] ;
    view.tintColor = [UIColor grayColor];
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    [header.textLabel setBackgroundColor:self.headerBGColor];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}


- (void)spinImageView:(UIImageView *)imageView  {
//    CABasicAnimation *rotation;
//    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotation.fromValue = [NSNumber numberWithFloat:0];
//    rotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
//    rotation.duration = 1.0; // Speed
//    rotation.repeatCount = 0; // Repeat forever. Can be a finite number.
//    [imageView.layer addAnimation:rotation forKey:@"Spin"];
    
//    //Create a CABasicAnimation object
//    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"transform.translation.x" ];
//    [move setFromValue:[NSNumber numberWithFloat:0.0f]];
//    [move setToValue:[NSNumber numberWithFloat:100.0f]];
//    [move setDuration:1.0f];
//    //Add animation to a specific element's layer. Must be called after the element is displayed.
//    [[imageView layer] addAnimation:move forKey:@"transform.translation.x"];
}



@end
