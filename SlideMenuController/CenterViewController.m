//
//  MasterViewController.m
//  SlideViewControllerDemo
//
//  Created by inoue on 2013/09/02.
//  Copyright (c) 2013年 Inoue Takayuki. All rights reserved.
//

#import "CenterViewController.h"
#import "AppDelegate.h"

@interface CenterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation CenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Center", @"Center");
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menu:)];
    self.navigationItem.leftBarButtonItem = menuButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }


    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (void)menu:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.slideMenuController.position == TKSlidePositionCenter) {
        [appDelegate.slideMenuController presentLeftViewControllerAnimated:YES];
    } else {
        [appDelegate.slideMenuController presentCenterViewControllerAnimated:YES];        
    }
}

@end
