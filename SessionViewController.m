//
//  ViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/5/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "SessionViewController.h"

#import <TwitterKit/TwitterKit.h>
#import <Parse/Parse.h>

#import "LocationService.h"
#import "UIColor+CustomColors.h"

@interface SessionViewController () <ABCIntroViewDelegate>

@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Twitter
    UIButton *loginButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*.8, 60)];
    //Originally + 100
    loginButton.center = CGPointMake(self.view.center.x, self.view.center.y + 180);
    loginButton.backgroundColor = [UIColor twitterBlueColor];
    loginButton.layer.borderColor = [UIColor twitterBlueColor].CGColor;
    loginButton.layer.borderWidth =.5;
    loginButton.layer.cornerRadius = 15;
    loginButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:18];
    [loginButton setTitle:@"Login with Twitter" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(parseTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];

    //Email
    self.emailButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.85, self.view.frame.size.width*.8, 60)];
    self.emailButton.backgroundColor = [UIColor redEmotionColor];
    self.emailButton.layer.borderColor = [UIColor redEmotionColor].CGColor;
    self.emailButton.layer.borderWidth =.5;
    self.emailButton.layer.cornerRadius = 15;
    self.emailButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:18];
    [self.emailButton setTitle:@"Use my email" forState:UIControlStateNormal];
    [self.emailButton addTarget:self action:@selector(emailLoginActions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.emailButton];


    //tests
    self.view.backgroundColor = [UIColor whiteColor];
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];

    //introview
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"intro_screen_viewed"]) {
        self.introView = [[ABCIntroView alloc] initWithFrame:self.view.frame];
        self.introView.delegate = self;
        self.introView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.introView];
    }
}

#pragma mark - Twitter login

- (void)parseTwitterLogin {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
            [self performSegueWithIdentifier:@"SessionToProfileInformation" sender:self];
        } else {
            NSLog(@"User logged in with Twitter!");
            [self performSegueWithIdentifier:@"SessionToSuccessfulLogin" sender:self];
        }
    }];
}

- (void)segueToTabBarController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:viewController animated:NO completion:NULL];
}

#pragma mark - Email login

- (void)emailLoginActions {
    [self performSegueWithIdentifier:@"SessionToEmailSignup" sender:self.emailButton];
}

//test
- (void)testLogLocation {
    NSLog(@"%@", [LocationService sharedInstance].currentLocation);
}

#pragma mark - ABCIntroViewDelegate Methods

-(void)onDoneButtonPressed{
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:@"YES"forKey:@"intro_screen_viewed"];
//        [defaults synchronize];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.introView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
