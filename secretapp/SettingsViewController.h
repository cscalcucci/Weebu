//
//  SettingsViewController.h
//  secretapp
//
//  Created by Bryon Finke on 6/29/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsService.h"
#import "UserVoice.h"

@interface SettingsViewController : UITableViewController


//UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *radiusPicker;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@property NSArray *pickerDisplay;
@property NSArray *pickerData;

@end
