//
//  ViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/5/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "WBSessionViewController.h"

#import <TwitterKit/TwitterKit.h>
#import <Parse/Parse.h>

#import "LocationService.h"
#import "UIColor+CustomColors.h"

@interface WBSessionViewController () <WBIntroViewDelegate>
@property UIImage *chaserImage;
@property UIImage *leaderImage;

@end

@implementation WBSessionViewController

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

    //Weebu label
    UILabel *mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    mainLabel.center = CGPointMake(self.view.center.x, 100);
    mainLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Black" size:60];
    mainLabel.textAlignment = NSTextAlignmentCenter;
    mainLabel.text = @"Weebu";
    [mainLabel setTintColor:[UIColor blackColor]];
    [self.view addSubview:mainLabel];

    //tests
    self.view.backgroundColor = [UIColor whiteColor];
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];

    //introview
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"intro_screen_viewed"]) {
        self.introView = [[WBIntroView alloc] initWithFrame:self.view.frame];
        self.introView.delegate = self;
        self.introView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.introView];
    }
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
    [self crossTheScreenActions];
}

#pragma mark - Imageview stuff

- (UIImageView *)addImageviewToView:(UIView *)view andEmotionImage:(UIImage *)image andXPosition:(int)xPos andYPosition:(int)yPos andWidth:(int)width andHeight:(int)height {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(xPos, yPos, width, height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
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

#pragma mark - Screen crossing animations

- (void)crossTheScreenActions {
    int leaderYPos = self.view.center.y - 50;
    self.leaderImage = [self flipImageWithImage:[UIImage imageNamed:@"emotion9white"]];
    UIImageView *leaderImageView = [self addImageviewToView:self.view andEmotionImage:self.leaderImage andXPosition:-500 andYPosition:leaderYPos andWidth:50 andHeight:50];
    [self expandImageView:leaderImageView];
    [self animateCrossTheScreen:leaderImageView andDuration:5 andDelay:0 andXPosition:750 andYPosition:leaderYPos andWidth:50 anHeight:50 andImage:self.leaderImage];

    for (int i = 1; i <= 20; i++) {
        int randA = arc4random() % 100 - 500;
        int randB = arc4random() % 100 + self.view.center.y - 100;
        //flip image
        self.chaserImage = [self flipImageWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"emotion%iwhite", i]]];
        UIImageView *chaserImageView = [self addImageviewToView:self.view andEmotionImage:self.chaserImage andXPosition: randA andYPosition:randB andWidth:50 andHeight:50];
        [self expandImageView:chaserImageView];
        [self animateCrossTheScreen:chaserImageView andDuration:5 andDelay:1 andXPosition:randA + 1000 andYPosition:randB andWidth:50 anHeight:50 andImage:self.chaserImage];
    }
}

- (void)animateCrossTheScreen:(UIImageView *)shape andDuration:(float)duration andDelay:(float)delay andXPosition:(int)xPos andYPosition:(int)yPos andWidth:(int)width anHeight:(int)height andImage:(UIImage *)image {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionRepeat
                     animations:^{
                         shape.frame = CGRectMake(xPos, yPos, width, height);
                     } completion:^(BOOL finished) {
                     }];
}

- (UIImage *)flipImageWithImage:(UIImage *)image {
        UIImage *sourceImage = image;
        UIImage *flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                    scale:sourceImage.scale orientation:UIImageOrientationUpMirrored];
    return flippedImage;
}

@end
