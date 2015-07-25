//
//  EmailSignupViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "WBEmailSignupViewController.h"

@implementation WBEmailSignupViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];

    //Rotating hell
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1750, 1750)];
    self.backgroundImageView.center = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
    self.backgroundImageView.image = [self imageNamed:@"colorWheel" withTintColor:[UIColor greenEmotionColor]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    [self performSelector:@selector(rotateImageView:) withObject:self.backgroundImageView afterDelay:0];

    //Email textfield
    self.emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.emailTextField.delegate = self;
    self.emailTextField.backgroundColor = [UIColor whiteColor];
    self.emailTextField.center = CGPointMake(self.view.center.x, self.view.center.y + 25);
    self.emailTextField.placeholder = @"Enter your e-mail";
    self.emailTextField.textAlignment = NSTextAlignmentCenter;
    self.emailTextField.autocorrectionType = FALSE;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.emailTextField];

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

#warning Do this!
    //Add login butont that segues to a loginview controller
    //Use the PFUser login with username function
//    [PFUser logInWithUsername:self.emailTextField.text password:self.passwordTextField.text];

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

#pragma mark - Submission stuff

- (void)submitButtonActions {
    [self validationTests];
}

- (void)validationTests {

    //Email validation
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if ([emailTest evaluateWithObject:self.emailTextField.text] == NO) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry." message:@"Please Enter Valid Email Address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    //Password validation
    if (self.passwordTextField.text.length <= 4) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry." message:@"You need to at least try a decent password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    //warning need more validation here, specifically cloud code to do a lookup on user

    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:self.emailTextField.text];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number > 0) {
            NSLog(@"YES!");
            [self segueToTabBarController];
        } else {
            [self userSignup];
        }
    }];

}

-(void)userSignup {
    PFUser *user = [PFUser new];
    user.username = self.emailTextField.text;
    user.email = self.emailTextField.text;
    user.password = self.passwordTextField.text;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
//            [self showAlert:@"Signup error" param2:error];
        } else {
            [self performSegueWithIdentifier:@"EmailSignupToProfileInformation" sender:self];
        }
    }];
}

- (void)segueToTabBarController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:viewController animated:NO completion:NULL];
}

-(void)dismissKeyboard {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return NO;
}

#pragma mark - Close

- (void)closeActions {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}


@end
