//
//  EmailSignupViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "EmailSignupViewController.h"

@implementation EmailSignupViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor blackColor];

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
    [self.closeButton setImage:[UIImage imageNamed:@"icon-close"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeActions) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];


    //Tap
    self.tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self
                action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:self.tap];
}

- (void)submitButtonActions {
    [self userSignup];
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
