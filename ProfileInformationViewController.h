//
//  ProfileInformationViewController.h
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import <TwitterKit/TwitterKit.h>
#import "UIColor+CustomColors.h"

@interface ProfileInformationViewController : UIViewController <UITextFieldDelegate>
@property UITextField *usernameTextField;
@property UIButton *submitButton;
@property UIButton *closeButton;
@property (nonatomic) UITapGestureRecognizer *tap;
@property UIImageView *backgroundImageView;


@end
