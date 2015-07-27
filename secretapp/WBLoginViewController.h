//
//  WBLoginViewController.h
//  secretapp
//
//  Created by John McClelland on 7/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import <TwitterKit/TwitterKit.h>
#import "UIColor+CustomColors.h"

#import "WBSuccessfulLoginViewController.h"

@interface WBLoginViewController : UIViewController <UITextFieldDelegate>

@property UITextField *usernameTextField;
@property UITextField *passwordTextField;
@property UIButton *submitButton;
@property UIButton *closeButton;
@property (nonatomic) UITapGestureRecognizer *tap;
@property UIImageView *backgroundImageView;


@end
