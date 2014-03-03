//
//  SFSessionsViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/1/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFSessionsViewController.h"

@interface SFSessionsViewController ()
@property(strong, nonatomic) NSMutableDictionary *sections;
@property(strong, nonatomic) NSArray *sortedStartTimes;
@property(strong, nonatomic) NSDateFormatter *dateToStringFormatter;

@end

@implementation SFSessionsViewController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"SessionsCustomCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"sessionCell"];
    
    NSString *str=@"http://localhost:3000/";
    NSURL *url=[NSURL URLWithString:str];
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    NSDictionary *groupedBySessions =[NSJSONSerialization JSONObjectWithData:data options:
                 NSJSONReadingMutableContainers error:&error];
    
    //NSLog(@"Your JSON Object: %@ Or Error is: %@", groupedBySessions, error);
    
     NSArray *groupedBySessionsArray = [groupedBySessions allValues];
     NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"Start_Date_And_Time__c" ascending: YES];
     groupedBySessionsArray = [groupedBySessionsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject: dateSortDescriptor]];
    
    //Used to convert Salesforce date+time string "2014-03-01T16:00:00.000+0000" to NSDate
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.zzzZ"];
    
    //Converts a NSDate to a readable string like: "10/10/2014 10:00PM"
    self.dateToStringFormatter = [[NSDateFormatter alloc] init];
    [self.dateToStringFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateToStringFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.sections = [NSMutableDictionary dictionary];
    for(id session in groupedBySessionsArray) {
        // Get NSDate from "2014-03-01T16:00:00.000+0000" string
        NSDate *currentStartTime = [df dateFromString: [session objectForKey:@"Start_Date_And_Time__c"]];
        
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
    for(id obj in unsortedDays) {
        NSLog(@"%@",obj);
    }
    self.sortedStartTimes = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@" section count: %d", [self.sections count]);

    for(id obj in self.sortedStartTimes) {
        NSLog(@" sorted: %@",obj);
    }
    NSLog(@" section count: %d", [self.sections count]);
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:section];
    NSArray *sessionsAtThisStartTime = [self.sections objectForKey:currentStartTime];
    return [sessionsAtThisStartTime count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDate *currentStartTime = [self.sortedStartTimes objectAtIndex:section];
    return [self.dateToStringFormatter  stringFromDate:currentStartTime];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sessionCell";
    SFSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SFSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
