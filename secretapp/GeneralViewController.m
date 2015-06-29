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

#include <math.h>
#import <ParseUI/ParseUI.h>

@interface GeneralViewController ()
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@property NSNumber *pleasantValue;
@property NSNumber *activatedValue;
@property Emotion *emotion;
@property (weak, nonatomic) IBOutlet PFImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UILabel *emotionLabel;
@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (void)viewWillAppear:(BOOL)animated {
    [self loadEvents];

    //Find location;
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"%@", self.userLocation);

    //Add button
    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:self.emotionLabel];
    [self.view bringSubviewToFront:self.emotionImageView];
}

#pragma mark - Emotion Calculation

- (void)loadEvents {
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery includeKey:@"emotionObject"];
    [eventsQuery orderByDescending:@"createdAt"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (!error) {
            self.events = events;
            [self calculatValues];
        }
    }];
}

- (void)calculatValues {
    int count = 0;
    NSNumber *pleasantSum = 0;
    NSNumber *activatedSum = 0;
    for (Event *event in self.events) {
        Emotion *emotion = event.emotionObject;
        NSLog(@"pleaseValue: %@", emotion.pleasantValue);
//        int pleasantValue = [[emotion.pleasantValue] intValue];
        pleasantSum = [NSNumber numberWithFloat:([pleasantSum floatValue] + [emotion.pleasantValue floatValue])];
//        int activatedValue = [[emotion.activatedValue] intValue];
//        activatedSum = activatedSum + emotion.activatedValue;
        activatedSum = [NSNumber numberWithFloat:([activatedSum floatValue] + [emotion.activatedValue floatValue])];
        count = count + 1;
    }
    NSLog(@"pleasantSum: %f", [pleasantSum floatValue]);
    NSLog(@"activatedSum: %f", [activatedSum floatValue]);
    self.pleasantValue = [NSNumber numberWithFloat:([pleasantSum floatValue]/count)];
    self.activatedValue = [NSNumber numberWithFloat:([activatedSum floatValue]/count)];
    NSLog(@"count: %i", count);
    NSLog(@"pleasntValue: %f", [self.pleasantValue floatValue]);
    NSLog(@"activatedValue: %f", [self.activatedValue floatValue]);
    [self findEmotion];
}

- (void)findEmotion {
    NSLog(@"finding emotion");
    __block NSNumber *distance = [[NSNumber alloc]initWithFloat:100];
    PFQuery *emotionsQuery = [PFQuery queryWithClassName:@"Emotion"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        for (Emotion *emotion in emotions) {
            NSNumber *x1 = emotion.pleasantValue;
            NSNumber *y1 = emotion.activatedValue;
            NSNumber *newDistance = [NSNumber numberWithFloat:sqrt(pow(([x1 floatValue]-[self.pleasantValue floatValue]), 2.0) + pow(([y1 floatValue]-[self.activatedValue floatValue]), 2.0))];
            NSLog(@"distance/newDistance: %f/%f", [distance floatValue], [newDistance floatValue]);
            if ([newDistance floatValue] < [distance floatValue]) {
                NSLog(@"ASSIGN");
                self.emotion = emotion;
                distance = newDistance;
            }
            NSLog(@"Distance: %f", [distance floatValue]);
        }
        NSLog(@"EMOTION: %@", self.emotion);
        NSLog(@"EMOTION name: %@", self.emotion.name);
        self.emotionImageView.file = self.emotion.imageFile;
        self.emotionLabel.text = self.emotion.name;
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
