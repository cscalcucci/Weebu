//
//  WBLoginViewController.m
//  secretapp
//
//  Created by John McClelland on 7/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "WBLoginViewController.h"

@implementation WBLoginViewController

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
    self.usernameTextField.center = CGPointMake(self.view.center.x, self.view.center.y + 25);
    self.usernameTextField.placeholder = @"Type in your username";
    self.usernameTextField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.usernameTextField];

    //Password textfield
    self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.passwordTextField.delegate = self;
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.center = CGPointMake(self.view.center.x, self.view.center.y + 90);
    self.passwordTextField.placeholder = @"Type in your password";
    self.passwordTextField.textAlignment = NSTextAlignmentCenter;
    self.passwordTextField.autocorrectionType = FALSE;
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.secureTextEntry = YES;
    [self.view addSubview:self.passwordTextField];

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

#pragma mark - Submit actions

- (void)submitButtonActions {
    if (self.usernameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nope." message:@"You need to enter a username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self userLogin];
}

- (void)userLogin {

    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if(!error) {
            NSLog(@"Login Successful.");
            WBSuccessfulLoginViewController *viewController = [WBSuccessfulLoginViewController new];
            [self presentViewController:viewController animated:YES completion:NULL];
        } else {
            NSLog(@"Error");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try again." message:@"Not a valid username / password combo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }];
}

-(void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return NO;
}

#pragma mark - Close

- (void)closeActions {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
