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
    [emotionsQuery orderByAscending:@"createdAt"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        if (!error) {
            NSLog(@"%lu", emotions.count);
            for (Emotion *emotion in emotions) {
                NSLog(@"%@", emotion.name);
            }
            self.emotions = emotions;
        }
    }];

    //Create carousel
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 100)];
    int x = 0;
    CGRect frame;
    for (int i = 0; i <= 19; i++) {

        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if (i == 0) {
            frame = CGRectMake(10, 10, 80, 80);
        } else {
            frame = CGRectMake((i * 80) + (i * 20) + 10, 10, 80, 80);
        }
        button.frame = frame;

        [button setTitle:[NSString stringWithFormat:@"Button %d", i] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"emotion%i",i]] forState:UIControlStateNormal];
        [button setTag:i];
        [button setBackgroundColor:[UIColor greenColor]];
                [button addTarget:self action:@selector(onSelectEmotionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];

        if (i == 19) {
            x = CGRectGetMaxX(button.frame);
        }
    }
    scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height);
    scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrollView];

}



#pragma mark - Add emotion buttons test

- (IBAction)onSelectEmotionPressed:(UIButton *)sender {
    NSLog(@"%li", sender.tag);
    self.selectedTag = sender.tag;
    Emotion *emotion = [self.emotions objectAtIndex:self.selectedTag];
    self.selectedEmotionLabel.text = emotion.name;
}

- (IBAction)onAddEmotionPressed:(id)sender {
    NSLog(@"add emotion button pressed");
    Event *event = [Event objectWithClassName:@"Event"];
        event.location = [PFGeoPoint geoPointWithLocation:[LocationService sharedInstance].currentLocation];
        event.createdBy = [PFUser currentUser];
        event.emotionObject = self.emotions[self.selectedTag];
        [event saveInBackground];
        [self performSelector:@selector(onCancelButtonPressed)];
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
