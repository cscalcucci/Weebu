//
//  ViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "GeneralViewController.h"
#import "Emotion.h"
#import "Event.h"

@interface GeneralViewController ()
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Find location;
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"%@", self.userLocation);
}

- (void)viewWillAppear:(BOOL)animated {
    [self calculateEmotion];

    //Find location;
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"%@", self.userLocation);

    //Add button
    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Emotion Calculation

- (void)calculateEmotion {
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery orderByDescending:@"createdAt"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (!error) {
            NSLog(@"total events: %lu", events.count);
            NSLog(@"%@", events.firstObject);
            self.events = events;

        }
    }];
}

#pragma mark - Floating button

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

#pragma mark - Segue

- (void)onAddEmotionButtonPressed {
    NSLog(@"pressed");
    [self performSegueWithIdentifier:@"GeneralToAdd" sender:self];
    
}

@end
