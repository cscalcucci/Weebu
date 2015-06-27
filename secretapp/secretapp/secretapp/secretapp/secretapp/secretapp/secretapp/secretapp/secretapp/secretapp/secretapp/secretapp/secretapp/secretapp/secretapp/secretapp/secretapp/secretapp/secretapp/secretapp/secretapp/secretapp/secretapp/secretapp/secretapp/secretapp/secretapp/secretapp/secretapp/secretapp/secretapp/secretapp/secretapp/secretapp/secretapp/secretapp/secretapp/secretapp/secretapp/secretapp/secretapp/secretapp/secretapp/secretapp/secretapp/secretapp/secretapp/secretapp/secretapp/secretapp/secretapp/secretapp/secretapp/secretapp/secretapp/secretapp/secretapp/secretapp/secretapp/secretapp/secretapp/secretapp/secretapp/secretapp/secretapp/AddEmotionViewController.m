//
//  AddEmotionViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "AddEmotionViewController.h"

@interface AddEmotionViewController ()

@end

@implementation AddEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.cancelButton = [self createButtonWithTitle:@"cancel" chooseColor:[UIColor redColor] andPosition:50];
    [self.cancelButton addTarget:self action:@selector(onCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark - Cancel button

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    int diameter = 65;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    button.center = CGPointMake(self.view.frame.size.width - position, self.view.frame.size.height - 100);
    button.layer.cornerRadius = button.bounds.size.width / 2;
    button.backgroundColor = color;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

- (void)onCancelButtonPressed {
    NSLog(@"pressed");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
