//
//  SettingsTableViewController.m
//  secretapp
//
//  Created by Bryon Finke on 7/2/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%lu", cell.tag);
    if (cell.tag == 2) {
        [UserVoice presentUserVoiceInterfaceForParentViewController:self];
    } else if (cell.tag == 3) {
        [PFUser logOutInBackground];
        [self performSegueWithIdentifier:@"SettingsToSplash" sender:self];
    }
}

@end
