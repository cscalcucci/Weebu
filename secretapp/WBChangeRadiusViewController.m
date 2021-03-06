//
//  ChangeRadiusViewController.m
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "WBChangeRadiusViewController.h"

@interface WBChangeRadiusViewController ()

@end

@implementation WBChangeRadiusViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.displayLabel.hidden = YES;
    self.displayLabel.text = @"unassigned";
    self.pickerDisplay = @[@"1 mile", @"2 miles", @"5 miles"];
    self.pickerData = @[@1, @2, @5];
    //    [self.radiusPicker selectRow:2 inComponent:1 animated:YES];
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerDisplay objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.displayLabel.hidden = NO;
    self.displayLabel.text = [self.pickerDisplay objectAtIndex:row];
    //    [SettingsService sharedInstance].radius = [NSNumber numberWithInt:[self.pickerData objectAtIndex:row]];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onFeedbackForum:(id)sender {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    return cell;
}

@end
