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

- (UIImageView *)createObjectWithImage:(UIImage *)image andPositions:(int)x :(int)y :(int)w :(int)h {
    double centerx = self.view.center.x;
    double centery = self.view.center.y;
    UIImageView *object = [[UIImageView alloc]initWithFrame:CGRectMake(centerx + x, centery + y, w, h)];
    object.center = CGPointMake(centerx + x, centery + y);
    object.image = image;
    [self.view addSubview:object];
    return object;
}

-(IBAction)unwindSelection:(UIStoryboardSegue *)segue {
}

@end