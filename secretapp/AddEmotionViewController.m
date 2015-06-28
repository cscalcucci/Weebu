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

    //Array with emotion objects

    self.emotions = [[NSArray alloc]init];
    PFQuery *emotionsQuery = [PFQuery queryWithClassName:@"Emotion"];
    [emotionsQuery orderByDescending:@"createdAt"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        if (!error) {
            NSLog(@"%lu", emotions.count);
            self.emotions = emotions;
        }
    }];
}



#pragma mark - Add emotion buttons test

- (IBAction)onSelectEmotionPressed:(UIButton *)sender {
    NSLog(@"%li", sender.tag);
    self.selectedTag = sender.tag;
    
    if (sender.tag == 0) {
        self.selectedEmotionLabel.text = @"Happy";
    } else if (sender.tag == 1) {
        self.selectedEmotionLabel.text = @"Sad";
    }
}

- (IBAction)onAddEmotionPressed:(id)sender {
    NSLog(@"add emotion button pressed");
    Event *event = [Event objectWithClassName:@"Event"];
    if ([self.selectedEmotionLabel.text  isEqual: @"Happy"]) {
        event.location = [PFGeoPoint geoPointWithLocation:[LocationService sharedInstance].currentLocation];
        event.createdBy = [PFUser currentUser];
        event.emotionObject = self.emotions[self.selectedTag];
        [event saveInBackground];
    }
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
