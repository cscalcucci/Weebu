//
//  AddEmotionViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "AddEmotionViewController.h"
#import "JFMinimalNotification.h"


@interface AddEmotionViewController () <JFMinimalNotificationDelegate>

@property UIImageView *imageView;
@property (nonatomic, strong) JFMinimalNotification* minimalNotification;
@property UIImage *selectedImage;
@property NSString *notificationTitle;
@property NSString *notificationMessage;
@property NSString *notificationType;
@property Emotion *selectedEmotion;


@end

@implementation AddEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateLocation:) name:@"selectedLocation"
     object:nil];


    //Setup container
    self.containerView.hidden = YES;
    self.nameView.hidden = YES;
    self.didSelectVenue = NO;

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
            NSLog(@"%lu", (unsigned long)emotions.count);
            for (Emotion *emotion in emotions) {
                NSLog(@"%@", emotion.name);
            }
            self.emotions = emotions;
        }
    }];

    //Setup MinimalNotification
    self.minimalNotification.delegate = self;

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
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(onSelectEmotionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];

        //Rainbow color
//        if (i == 1 | i == 6 | i == 11 | i == 16) {
//            [button setTintColor:[UIColor redEmotionColor]];
//        } else if (i == 2 | i == 7 | i == 12 | i == 17) {
//            [button setTintColor:[UIColor orangeEmotionColor]];
//        } else if (i == 3 | i == 8 | i == 13 | i == 18) {
//            [button setTintColor:[UIColor yellowEmotionColor]];
//        } else if (i == 4 | i == 9 | i == 14 | i == 19) {
//            [button setTintColor:[UIColor greenEmotionColor]];
//        } else if (i == 5 | i == 10 | i == 15) {
//            [button setTintColor:[UIColor blueEmotionColor]];
//        }
        [button setTintColor:[UIColor blackColor]];

        if (i == 19) {
            x = CGRectGetMaxX(button.frame);
        }
    }
    scrollView.contentSize = CGSizeMake(x, scrollView.frame.size.height);
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
}


-(void)updateLocation:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[FoursquareAPI class]]) {
        FoursquareAPI *item = [notification object];
        self.selectedItem = [FoursquareAPI new];
        self.selectedItem = item;
        self.addVenue.titleLabel.text = item.venueName;
        self.containerView.hidden = YES;
        self.didSelectVenue = YES;
    } else {
        NSLog(@"Error Transferring Location Data");
    }
}


-(void)viewDidAppear:(BOOL)animated {
    [[LocationService sharedInstance] startUpdatingLocation];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    [mixpanel timeEvent:@"Add emotion"];
}

-(void)viewWillDisappear:(BOOL)animated {
    //Add code to stop updating location
}

#pragma mark - Button actions

- (IBAction)onSelectEmotionPressed:(UIButton *)sender {
    NSLog(@"%li", (long)sender.tag);
    self.selectedTag = sender.tag;
    Emotion *emotion = [self.emotions objectAtIndex:self.selectedTag];
    self.addEmotion.titleLabel.text = @"Emote";
    self.selectedEmotionLabel.text = emotion.name;
//    self.selectedEmotionLabel.center = self.nameView.center;
    self.selectedEmotionLabel.hidden = NO;
    self.nameView.hidden = NO;

    self.imageView.image = [UIImage imageNamed:emotion.imageString];
}

- (void)onAddEmotionButtonPressed {
    NSLog(@"add emotion button pressed");
    Event *event = [Event objectWithClassName:@"Event"];

        self.selectedEmotion = self.emotions[self.selectedTag];
        self.selectedImage = [UIImage imageNamed:self.selectedEmotion.imageString];

        event.createdBy = [PFUser currentUser];
        event.emotionObject = self.emotions[self.selectedTag];
        event.venueName = self.selectedItem.venueName;

        if (self.didSelectVenue) {
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.selectedItem.latitude longitude:self.selectedItem.longitude];
                event.location = geoPoint;
        } else {
            event.location = [PFGeoPoint geoPointWithLocation:[LocationService sharedInstance].currentLocation];
        }

        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                int chance = (arc4random_uniform(5));
                if (chance == 3) {
                    self.notificationType = [[NSString alloc] initWithFormat:@"chance"];
                } else {
                    self.notificationType = [[NSString alloc] initWithFormat:@"success"];
                }
                NSLog(@"Success");
            } else {
                self.notificationType = [[NSString alloc] initWithFormat:@"error"];
                [self reloadInputViews];
                NSLog(@"Error");
            }

            [self displayNotification];
        }];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Add emotion"];
}

-(void)displayNotification {
    [self setNotificationForType];

    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:self.notificationTitle subTitle:self.notificationMessage dismissalDelay:1.5 touchHandler:^{
        [self.minimalNotification dismiss];
    }];

    [self.view addSubview:self.minimalNotification];

    if ([self.notificationType isEqualToString:@"success"]) {

        [self.minimalNotification setStyle:JFMinimalNotificationStyleSuccess animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:self.selectedImage] animated:YES];
        [self performSelector:@selector(onCancelButtonPressed) withObject:self afterDelay:2.0];

    } else if ([self.notificationType isEqualToString:@"error"]) {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleError animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deathSD"]] animated:YES];
    } else {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleWarning animated:YES];
    }

    UIFont* titleFont = [UIFont fontWithName:@"STHeitiK-Light" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"STHeitiK-Light" size:16];
    [self.minimalNotification setSubTitleFont:subTitleFont];

    [self.minimalNotification show];
}

-(void)setNotificationForType {
    if ([self.notificationType isEqualToString:@"chance"]) {
        self.notificationTitle = [NSString stringWithFormat:@"Watch out!"];
        self.notificationMessage = [NSString stringWithFormat:@"We believe you MIGHT be %@!, but we're onto you!", self.selectedEmotion.name];

    } else if ([self.notificationType isEqualToString:@"success"]) {
        self.notificationTitle = [NSString stringWithFormat:@"Huzzah!"];
        self.notificationMessage = [NSString stringWithFormat:@"You are now %@!", self.selectedEmotion.name];

    } else if ([self.notificationType isEqualToString:@"error"]) {
        self.notificationTitle = [NSString stringWithFormat:@"Oh No!"];
        self.notificationMessage = [NSString stringWithFormat:@"You must not be very %@! Try uploading again.", self.selectedEmotion.name];
    }
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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Add emotion"];

    [self dismissViewControllerAnimated:YES completion:NULL];

}

- (IBAction)unwindToEmotion:(UIStoryboardSegue *)segue {
}




@end
