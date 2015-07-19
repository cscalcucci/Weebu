//
//  ProfileInformationViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "WBProfileInformationViewController.h"

@implementation WBProfileInformationViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];

    //Rotating hell
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1750, 1750)];
    self.backgroundImageView.center = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
    self.backgroundImageView.image = [self imageNamed:@"colorWheel" withTintColor:[UIColor blueEmotionColor]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self performSelector:@selector(rotateImageView:) withObject:self.backgroundImageView afterDelay:0];

    //Username textfield
    self.usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.usernameTextField.delegate = self;
    self.usernameTextField.backgroundColor = [UIColor whiteColor];
    self.usernameTextField.center = CGPointMake(self.view.center.x, self.view.center.y + 90);

    //Use Twitter username as placeholder if avail
    NSString *twitterUsername = [PFTwitterUtils twitter].screenName;
    if (!twitterUsername) {
        self.usernameTextField.placeholder = @"Pick a username";
    } else {
        self.usernameTextField.text = twitterUsername;
    }
    self.usernameTextField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.usernameTextField];

    //Submit button
    self.submitButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.85, self.view.frame.size.width*.8, 60)];
    self.submitButton.backgroundColor = [UIColor redEmotionColor];
    self.submitButton.layer.borderColor = [UIColor redEmotionColor].CGColor;
    self.submitButton.layer.borderWidth =.5;
    self.submitButton.layer.cornerRadius = 15;
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitButtonActions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];

    //Close button
    self.closeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, 30, 40, 40)];
    [self.closeButton setImage:[self imageNamed:@"icon-close" withTintColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeActions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];

    //Tap
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:self.tap];
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

#pragma mark - Username verification

//Have username verification
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"Editing text field");
    return true;
}

#pragma mark - Twitter e-mail

//Figure out how to acquire the user's e-mail informatio


#pragma mark - Submit actions

- (void)submitButtonActions {
    if (self.usernameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nope." message:@"You need to enter a username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self userSignup];
}

- (void)userSignup {
    PFUser *user = [PFUser currentUser];
    user.username = self.usernameTextField.text;
    [user saveInBackground];

    //Perform segue, consider adding some validation with textfield did edit to check username
    [self performSegueWithIdentifier:@"ProfileInformationToSuccessfulLogin" sender:self];
    NSLog(@"%@", user.username);
}

-(void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.usernameTextField resignFirstResponder];
    return NO;
}

#pragma mark - Close

- (void)closeActions {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
