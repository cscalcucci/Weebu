//
//  SessionViewController.m
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "SessionViewController.h"

@interface SessionViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor paperColor];
    self.loginButton.backgroundColor = [UIColor
                                        colorWithRed:0.518
                                        green:0.894
                                        blue:0.345
                                        alpha:1];
    self.signupButton.backgroundColor = [UIColor
                                         colorWithRed:0.890
                                         green:0.376
                                         blue:0.494
                                         alpha:1];
}