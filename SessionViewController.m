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

    //Rotating hell
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1750, 1750)];
    self.backgroundImageView.center = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
    self.backgroundImageView.image = [self imageNamed:@"colorWheel" withTintColor:[UIColor orangeEmotionColor]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self performSelector:@selector(rotateImageView:) withObject:self.backgroundImageView afterDelay:0];

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

- (void)viewDidAppear:(BOOL)animated {
    UIImageView *imageView = [self addImageviewToView:self.view andEmotionImage:@"emotion9white" andXPosition:-100 andYPosition:self.view.center.y andWidth:50 andHeight:50];
    [self expandImageView:imageView];
    [self crossTheScreen:imageView];
}

#pragma mark - Rotating colorwheel

- (UIImage *)imageNamed:(NSString *) name withTintColor: (UIColor *) tintColor {

    UIImage *baseImage = [UIImage imageNamed:name];
    CGRect drawRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);

    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, drawRect, baseImage.CGImage);

    // draw color atop
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, drawRect);

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

- (void)rotateImageView:(UIImageView *)shape {
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 20;
    fullRotation.repeatCount = 100;
    [shape.layer addAnimation:fullRotation forKey:@"360"];
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

#pragma mark - Imageview stuff

- (UIImageView *)addImageviewToView:(UIView *)view andEmotionImage:(NSString *)imageString andXPosition:(int)xPos andYPosition:(int)yPos andWidth:(int)width andHeight:(int)height {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:imageString];
    [view addSubview:imageView];
    return imageView;
}

- (void)expandImageView:(UIImageView *)shape {
    [UIView animateWithDuration:2.0
                          delay:2.0f
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse
                     animations:^{
                         shape.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:2.0 animations:^{
                             shape.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

- (void)crossTheScreen:(UIImageView *)shape {
    [UIView animateWithDuration:2
                          delay:2
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse
                     animations:^{
                         shape.frame = CGRectMake(500, self.view.center.y, 50, 50);
                     } completion:^(BOOL finished) {
//                         shape.frame = CGRectMake(0, 600, 50, 50);
                     }];
}

@end
