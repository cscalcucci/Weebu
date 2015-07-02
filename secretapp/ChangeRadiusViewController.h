//
//  ChangeRadiusViewController.h
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeRadiusViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *radiusPicker;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@property NSArray *pickerDisplay;
@property NSArray *pickerData;

@end
