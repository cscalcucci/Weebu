//
//  AddEmotionViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddEmotionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *selectedEmotionLabel;
@property UIButton *cancelButton;

@end
