//
//  LoginViewController.m
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *loginNav;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor paperColor];
    self.loginNav.topItem.title = @"Log In";
    self.passwordTextField.secureTextEntry = YES;
    self.usernameTextField.placeholder = @"username";
    self.passwordTextField.placeholder = @"password";
    [self.usernameTextField becomeFirstResponder];
//    [self.loginButton setHidden:YES];
    self.loginButton.backgroundColor = [UIColor
                                        colorWithRed:0.235
                                        green:0.235
                                        blue:0.235
                                        alpha:1];

}

- (IBAction)onLoginTapped:(UIButton *)sender {
    [self userLogIn];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([PFUser currentUser] == nil) {
        [self userLogIn];
    } else {

    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.passwordTextField.isFirstResponder) {
        [self.loginButton setHidden:NO];
    }

    return YES;
}

-(void)userLogIn {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (!error) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PrimaryView" bundle:[NSBundle mainBundle]];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RootViewController"];
            [self presentViewController:viewController animated:NO completion:NULL];
        } else {
            [self showAlert:@"Login error" param2:error];
        }
    }];
}

-(void)showAlert:(NSString *)message param2:(NSError *)error {
    UIAlertView *alert = [UIAlertView new];
    alert.title = message;
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"Dismiss"];
    alert.delegate = self;
    [alert show];
}

@end
