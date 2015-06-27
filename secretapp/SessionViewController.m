//
//  SessionViewController.m
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "SessionViewController.h"

@interface SessionViewController ()
@property PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *sessionImage;
@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (void)viewDidAppear:(BOOL)animated {
    [self checkCurrentUser];
}

- (void)checkCurrentUser {
    if ([PFUser currentUser] != nil) {
        self.currentUser = [PFUser currentUser];
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        [self presentViewController:viewController animated:NO completion:NULL];
    }
}

-(IBAction)unwindSelection:(UIStoryboardSegue *)segue {
}

@end