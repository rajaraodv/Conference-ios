//
//  SFFilterViewController.m
//  Conference
//
//  Created by Raja Rao DV on 3/12/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SFFilterViewController.h"

@interface SFFilterViewController ()

@end

@implementation SFFilterViewController

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

    // Below code removes 'empty' table cells (i.e. if there are less tracks than # of cells)
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 0)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = footerView;
    
    //used to make chackmark white
    self.tableView.tintColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString* text =  [self.tracks objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    if ([self.selectedTrack isEqualToString: text] || (self.selectedTrack == nil && [text isEqualToString:@"None"])) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];//deselect
    self.selectedTrack = [self.tracks objectAtIndex:indexPath.row];
    [self.sessionsViewController setCurrentFilter:self.selectedTrack];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
