//
//  EmailSignupViewController.h
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "UIColor+CustomColors.h"

@interface WBEmailSignupViewController : UIViewController <UITextFieldDelegate>
@property UITextField *emailTextField;
@property UITextField *passwordTextField;
@property UIButton *submitButton;
@property UIButton *closeButton;
@property (nonatomic) UITapGestureRecognizer *tap;
@property UIImageView *backgroundImageView;

@end
