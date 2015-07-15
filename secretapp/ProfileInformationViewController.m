//
//  ProfileInformationViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "ProfileInformationViewController.h"

@implementation ProfileInformationViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor mintGreenColor];

    //Username textfield
    self.usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    self.usernameTextField.delegate = self;
    self.usernameTextField.backgroundColor = [UIColor whiteColor];
    self.usernameTextField.center = CGPointMake(self.view.center.x, self.view.center.y + 90);
    self.usernameTextField.placeholder = @"Pick a username";
    self.usernameTextField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.usernameTextField];

    //Submit button
    self.submitButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.85, self.view.frame.size.width*.8, 60)];
    self.submitButton.backgroundColor = [UIColor peonyColor];
    self.submitButton.layer.borderColor = [UIColor twitterBlueColor].CGColor;
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
