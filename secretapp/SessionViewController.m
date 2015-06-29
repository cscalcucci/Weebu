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
@property UIButton *loginButton;
@property UIButton *signupButton;
@property UIButton *twitterButton;
@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sessionImage= [self createObjectWithImage:[UIImage imageNamed:@"happy"] andPositions:0 :0 :65 :65];

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



    self.twitterButton = [self createButtonWithTitle:@"twitter" chooseColor:[UIColor blueEmotionColor] andPosition:3];
    [self.twitterButton addTarget:self action:@selector(parseTwitterLogin) forControlEvents:UIControlEventTouchUpInside];

    self.loginButton = [self createButtonWithTitle:@"login" chooseColor:[UIColor greenEmotionColor] andPosition:2];
    [self.loginButton addTarget:self action:@selector(loginSegue) forControlEvents:UIControlEventTouchUpInside];

    self.signupButton = [self createButtonWithTitle:@"signup" chooseColor:[UIColor redEmotionColor] andPosition:1];
    [self.signupButton addTarget:self action:@selector(signupSegue) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [self checkCurrentUser];
}

- (void)checkCurrentUser {
    if ([PFUser currentUser] != nil) {
        self.currentUser = [PFUser currentUser];
        [self gotoTabBarController];
    }
}

- (void)parseTwitterLogin {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
        } else {
            NSLog(@"User logged in with Twitter!");
            [self gotoTabBarController];
        }
    }];
}

- (void)gotoTabBarController {
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:viewController animated:NO completion:NULL];
}

- (UIImageView *)createObjectWithImage:(UIImage *)image andPositions:(int)x :(int)y :(int)w :(int)h {
    double centerx = self.view.center.x;
    double centery = self.view.center.y;
    UIImageView *object = [[UIImageView alloc]initWithFrame:CGRectMake(centerx + x, centery + y, w, h)];
    object.center = CGPointMake(centerx + x, centery + y);
    object.image = image;
    [self.view addSubview:object];
    return object;
}

#pragma mark - Full screen width buttons

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    int diameter = 65;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (diameter * position), self.view.frame.size.width, diameter)];
    button.backgroundColor = color;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

- (void)loginSegue {
    [self performSegueWithIdentifier:@"SessionToLogin" sender:self];
}

- (void)signupSegue {
    [self performSegueWithIdentifier:@"SessionToSignup" sender:self];
}


-(IBAction)unwindSelection:(UIStoryboardSegue *)segue {
}

@end