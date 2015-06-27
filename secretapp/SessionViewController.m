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
                                        colorWithRed:0.235
                                        green:0.235
                                        blue:0.235
                                        alpha:1];
    self.signupButton.backgroundColor = [UIColor
                                         colorWithRed:0.157
                                         green:0.157
                                         blue:0.157
                                         alpha:1];
}

@end