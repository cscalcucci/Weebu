//
//  SettingsViewController.m
//  secretapp
//
//  Created by Bryon Finke on 6/29/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsService.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *radiusPicker;
@property NSArray *pickerDisplay;
@property NSArray *pickerData;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

//    self.displayLabel.text = [self.pickerDisplay objectAtIndex:row];
//    [SettingsService sharedInstance].radius = [NSNumber numberWithInt:[self.pickerData objectAtIndex:row]];
//    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
