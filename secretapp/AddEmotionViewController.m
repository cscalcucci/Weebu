//
//  AddEmotionViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "AddEmotionViewController.h"

@interface AddEmotionViewController ()

@property UIImageView *imageView;

@end

@implementation AddEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    //Setup container
    self.containerView.hidden = YES;

    self.addEmotion = [self createButtonWithTitle:@"addEmotion" chooseColor:[UIColor greenColor] andPosition:3];
    [self.addEmotion addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.addVenue = [self createButtonWithTitle:@"add venue" chooseColor:[UIColor blueEmotionColor] andPosition:2];
    [self.addVenue addTarget:self action:@selector(onSelectVenueButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.cancelButton = [self createButtonWithTitle:@"cancel" chooseColor:[UIColor redEmotionColor] andPosition:1];
    [self.cancelButton addTarget:self action:@selector(onCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width - 75, self.view.frame.size.width - 75)];
    self.imageView.center = self.view.center;
    self.imageView.image = [UIImage imageNamed:@"emotion0"];
    [self.view addSubview:self.imageView];


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
        [button setBackgroundColor:[UIColor greenEmotionColor]];
                [button addTarget:self action:@selector(onSelectEmotionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];

        if (i == 19) {
            x = CGRectGetMaxX(button.frame);
        }
    }
    scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height);
    scrollView.backgroundColor = [UIColor redEmotionColor];
    [self.view addSubview:scrollView];
}

-(void)viewDidAppear:(BOOL)animated {
    [[LocationService sharedInstance] startUpdatingLocation];
}

-(void)viewWillDisappear:(BOOL)animated {
    //Add code to stop updating location
}

#pragma mark - Button actions

- (IBAction)onSelectEmotionPressed:(UIButton *)sender {
    NSLog(@"%li", sender.tag);
    self.selectedTag = sender.tag;
    Emotion *emotion = [self.emotions objectAtIndex:self.selectedTag];
    self.selectedEmotionLabel.text = emotion.name;
    self.imageView.image = [UIImage imageNamed:emotion.imageString];
}

- (void)onAddEmotionButtonPressed {
    NSLog(@"add emotion button pressed");
    Event *event = [Event objectWithClassName:@"Event"];
        event.location = [PFGeoPoint geoPointWithLocation:[LocationService sharedInstance].currentLocation];
        event.createdBy = [PFUser currentUser];
        event.emotionObject = self.emotions[self.selectedTag];
        [event saveInBackground];
        [self performSelector:@selector(onCancelButtonPressed)];
}

- (void)onSelectVenueButtonPressed {
    self.containerView.hidden = !self.containerView.hidden;
    if (self.containerView.hidden == NO) {
        [self.view bringSubviewToFront:self.containerView];
    }
}

#pragma mark - Full screen width buttons

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    int diameter = 65;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (diameter * position), self.view.frame.size.width, diameter)];
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
