//
//  ViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "GeneralViewController.h"


@interface GeneralViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.settingsButton.title = @"";
    UIImage* image3 = [UIImage imageNamed:@"settings"];
    [self.settingsButton setBackgroundImage:image3 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadEvents];

//    [self.emotionLabel setFont:[UIFont fontNamesForFamilyName:@"Brandon Grotesque"]];

    //Find location;
    self.userLocation = [LocationService sharedInstance].currentLocation;

    //Add button
    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:self.emotionLabel];
    [self.view bringSubviewToFront:self.emotionImageView];

    [self performSelector:@selector(expandImageView:) withObject:self.emotionImageView afterDelay:0.05];

}

#pragma mark - Emotion Calculation

- (void)loadEvents {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"user location for feed: %@", self.userLocation);
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.userLocation.coordinate.latitude
                                                      longitude:self.userLocation.coordinate.longitude];
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:[[SettingsService sharedInstance].radius floatValue]];
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-24*60*60];
    [eventsQuery whereKey:@"createdAt" greaterThan:date];
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
            NSLog(@"%@ %@/%@", emotion.name, emotion.pleasantValue, emotion.activatedValue);
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
        [self.emotionImageView loadInBackground];
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

#pragma mark - Animations

- (void)expandImageView:(UIImageView *)shape {
    [UIView animateWithDuration:2.0
                          delay:2.0f
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse
                     animations:^{
                         shape.transform = CGAffineTransformMakeScale(1.05, 1.05);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:2.0 animations:^{
                             shape.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

@end
