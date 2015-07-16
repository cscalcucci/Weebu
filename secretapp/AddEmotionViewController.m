//
//  AddEmotionViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "AddEmotionViewController.h"
#import "JFMinimalNotification.h"


@interface AddEmotionViewController () <JFMinimalNotificationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property UIImageView *imageView;
@property (nonatomic, strong) JFMinimalNotification* minimalNotification;
@property UIImage *selectedImage;
@property NSString *notificationTitle;
@property NSString *notificationMessage;
@property NSString *notificationType;
@property Emotion *selectedEmotion;

//Emotion Select View
@property (nonatomic) UIView *emotionSelectView;
@property (nonatomic) UIButton *selectEmotion;
@property (nonatomic) UIButton *emotionEmotion;
//@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIPickerView *emotionPicker;


//Venue Select View
@property (nonatomic) UIView *venueSelectView;
@property (nonatomic) UIButton *venuesButton;
@property (nonatomic) UIButton *confirmButton;
@property (nonatomic) UIButton *venueEmotion;
@property (nonatomic) UITextField *captionText;

//VC-Wide Elements
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UIView *venuesContainer;
@property (nonatomic) UITapGestureRecognizer *tap;

@end

@implementation AddEmotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.venuesContainer.hidden = YES;

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateLocation:) name:@"selectedLocation"
     object:nil];

    PFQuery *emotionsQuery = [PFQuery queryWithClassName:@"Emotion"];
    [emotionsQuery orderByAscending:@"createdAt"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        if (!error) {
            self.emotions = emotions;
            [self.emotionPicker reloadAllComponents];
        }
    }];

    self.tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:self.tap];

    //Select Venue View & Buttons
    self.venueSelectView = [[UIView alloc] initWithFrame: CGRectMake(1000, (self.view.frame.size.height - 395), self.view.frame.size.width, 345)];
    self.captionText = [[UITextField alloc] initWithFrame: CGRectMake(0, 50, self.view.frame.size.width, 135)];
    self.captionText.textAlignment = NSTextAlignmentCenter;
    self.captionText.enablesReturnKeyAutomatically = YES;
    self.captionText.placeholder = [NSString stringWithFormat:@"   enter caption"];
    self.captionText.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:24];

    self.venueEmotion = [[UIButton alloc] initWithFrame: CGRectMake(0, 135, self.view.frame.size.width, 40) ];
    self.venueEmotion.backgroundColor = [UIColor clearColor];
    [self.venueEmotion setTitle:@"emotion" forState:UIControlStateNormal];

/*
    self.venuesButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 195, 75, 75) ];
    self.venuesButton.backgroundColor = [UIColor blueEmotionColor];
    self.venuesButton.layer.cornerRadius = (75 / 2);
    [self.venuesButton setTitle:@"venue" forState:UIControlStateNormal];
    [self.venuesButton addTarget:self action:@selector(onVenueButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
*/

    self.confirmButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 270, self.view.frame.size.width, 75)];
    self.confirmButton.backgroundColor = [UIColor greenEmotionColor];
    [self.confirmButton setTitle:@"confirm" forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:22];
    [self.confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];



    [self.view addSubview:self.venueSelectView];
    [self.venueSelectView addSubview:self.confirmButton];
    [self.venueSelectView addSubview:self.captionText];
    [self.venueSelectView addSubview:self.venuesButton];
    [self.venueSelectView addSubview:self.venueEmotion];
    self.venueSelectView.hidden = YES;

    //Select Emotion View & Buttons
    self.emotionSelectView = [[UIView alloc] initWithFrame: CGRectMake(0, (self.view.frame.size.height - 395), self.view.frame.size.width, 395)];

//    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 80)];
    self.emotionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 150)];

    self.selectEmotion = [[UIButton alloc] initWithFrame: CGRectMake(0, 270, self.view.frame.size.width, 75)];
    self.selectEmotion.backgroundColor = [UIColor greenEmotionColor];
    self.selectEmotion.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:22];
    [self.selectEmotion setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.selectEmotion setTitle:@"select emotion" forState:UIControlStateNormal];
    [self.selectEmotion addTarget:self action:@selector(selectEmotionTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.emotionSelectView];
    [self.emotionSelectView addSubview:self.emotionPicker];
    [self.emotionSelectView addSubview:self.emotionEmotion];
    [self.emotionSelectView addSubview:self.selectEmotion];

    [self.view bringSubviewToFront:self.emotionSelectView];
    [self.emotionSelectView bringSubviewToFront:self.emotionPicker];
    [self.emotionSelectView bringSubviewToFront:self.emotionEmotion];
    [self.emotionSelectView bringSubviewToFront:self.selectEmotion];

    //View Controller Buttons
    self.cancelButton = [[UIButton alloc] initWithFrame: CGRectMake((self.view.frame.size.width - 80), 60, 80, 80)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setTitle:@"< back" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:22];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton setTitle:@"x" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(onCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];


    self.backButton = [[UIButton alloc] initWithFrame: CGRectMake(-80, 60, 80, 80)];

    self.backButton.backgroundColor = [UIColor clearColor];
    [self.backButton setTitle:@"< back" forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:22];
    [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.backButton];
    [self.view addSubview:self.cancelButton];
//    self.backButton.hidden = YES;

    //Setup Image View
    self.emotionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emotion0"]];
    float width = self.view.frame.size.width / 2;
    float height = width;

//    self.emotionImageView.frame = CGRectMake((width - (width / 2)), ((self.view.frame.size.height - self.venueSelectView.frame.size.height) - (height + ((height / 2) - 30))), width, height);
    self.emotionImageView.frame = CGRectMake(0, 0, width, height);
    self.emotionImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    [self.view addSubview:self.emotionImageView];

    //Array with emotion objects
    self.emotions = [[NSArray alloc]init];

    // Setup Minimal Notifications
    self.minimalNotification.delegate = self;
    self.emotionPicker.delegate = self;
    self.captionText.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [self.emotionPicker selectRow:10 inComponent:0 animated:YES];
    
    [[LocationService sharedInstance] startUpdatingLocation];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel timeEvent:@"Add emotion"];
}

-(void)dismissKeyboard {
    [self.captionText resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.captionText resignFirstResponder];
    return NO;
}

-(void)updateLocation:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[FoursquareAPI class]]) {
        NSLog(@"Did select a venue");
        FoursquareAPI *item = [notification object];
        self.selectedItem = [FoursquareAPI new];
        self.selectedItem = item;
        self.venuesButton.titleLabel.text = item.venueName;
        self.venuesContainer.hidden = YES;
        self.didSelectVenue = YES;
        self.tap.enabled = YES;
        self.captionText.hidden = NO;
    } else {
        NSLog(@"Error Transferring Location Data");
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    //Add code to stop updating location
}

#pragma mark - Button Taps

- (IBAction)backButtonTapped:(UIButton *)sender {
    [self moveView];
}

- (IBAction)onCancelButtonPressed:(UIButton *)sender {
    [self cancelEmotion];
}

//Buttons in Select Emotion View
- (IBAction)selectEmotionTapped:(UIButton *)sender {
    [self moveView];
}

//Buttons in Select Venue View
- (IBAction)confirmButtonTapped:(UIButton *)sender {
    [self submitEmotion];
}

- (IBAction)onVenueButtonPressed:(UIButton *)sender {
    [self selectVenue];
}

#pragma mark - Emotions Carousel
/*
-(void)createCarousel {
    int x = 0;
    CGRect frame;

    for (int i = 0; i <= 19; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if (i == 0) {
            frame = CGRectMake(10, 10, 60, 60);
        } else {
            frame = CGRectMake((i * 80) + (i * 20) + 10, 10, 60, 60);
        }
        button.frame = frame;

        [button setTitle:[NSString stringWithFormat:@"Button %d", i] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"emotion%i",i]] forState:UIControlStateNormal];
        [button setTag:i];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(onSelectEmotionPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];

        [button setTintColor:[UIColor blackColor]];

        if (i == 19) {
            x = CGRectGetMaxX(button.frame);
        }
    }
    self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.size.height);
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.emotionSelectView addSubview:self.scrollView];
    [self.emotionSelectView bringSubviewToFront:self.scrollView];

}
*/

- (IBAction)onSelectEmotionPressed:(UIButton *)sender {
    self.selectedTag = sender.tag;
    Emotion *emotion = [self.emotions objectAtIndex:self.selectedTag];
    [self.venueEmotion setTitle:emotion.name forState:UIControlStateNormal];
    [self.emotionEmotion setTitle:emotion.name forState:UIControlStateNormal];

    self.emotionImageView.image = [UIImage imageNamed:emotion.imageString];
}

#pragma mark - Emotions picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSLog(@"Number of Components");
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.emotions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Emotion *emotion = [self.emotions objectAtIndex:row];
    return emotion.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.emotionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"emotion%i",(int)row]];
    self.selectedTag = row;
}


#pragma mark - Button actions

- (void)submitEmotion {
    NSLog(@"add emotion button pressed");
    Event *event = [Event objectWithClassName:@"Event"];

        self.selectedEmotion = self.emotions[self.selectedTag];
        self.selectedImage = [UIImage imageNamed:self.selectedEmotion.imageString];

        event.createdBy = [PFUser currentUser];
        event.emotionObject = self.emotions[self.selectedTag];
        event.venueName = self.selectedItem.venueName;
        event.caption = self.captionText.text;

        if (self.didSelectVenue) {
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.selectedItem.latitude longitude:self.selectedItem.longitude];
                event.location = geoPoint;
        } else {
            event.location = [PFGeoPoint geoPointWithLocation:[LocationService sharedInstance].currentLocation];
        }

        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //Removed fun little chance for alternative notification
//                int chance = (arc4random_uniform(5));
//                if (chance == 3) {
//                    self.notificationType = [[NSString alloc] initWithFormat:@"chance"];
//                } else {
                    self.notificationType = [[NSString alloc] initWithFormat:@"success"];
//                }
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

- (void)selectVenue {
    self.venuesContainer.hidden = !self.venuesContainer.hidden;
    if (self.venuesContainer.hidden == NO) {
        [self.view bringSubviewToFront:self.venuesContainer];
        self.tap.enabled = NO;
        self.captionText.hidden = YES;
    }
}

- (void)cancelEmotion {
    NSLog(@"pressed");
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Add emotion"];

    [self dismissViewControllerAnimated:YES completion:NULL];

}

-(void)moveView {
    self.emotionSelectView.hidden = !self.emotionSelectView.hidden;
    self.venueSelectView.hidden = !self.venueSelectView.hidden;
//    self.backButton.hidden = !self.backButton.hidden;

    CGRect venueFrame;
    CGRect emotionFrame;
    CGRect backFrame;

    if (self.emotionSelectView.hidden) {
        NSLog(@"Forward");
        venueFrame = CGRectMake(0, (self.view.frame.size.height - 395), self.view.frame.size.width, 345);
        emotionFrame = CGRectMake((0 - (self.view.frame.size.width)), self.view.frame.size.height - 395, self.view.frame.size.width, 345);
        backFrame = CGRectMake(0, 60, 80, 80);

    } else {
        NSLog(@"Backward");
        venueFrame = CGRectMake(self.view.frame.size.width, (self.view.frame.size.height - 395), self.view.frame.size.width, 345);
        emotionFrame = CGRectMake(0, self.view.frame.size.height - 395, self.view.frame.size.width, 345);
        backFrame = CGRectMake(-80, 60, 80, 80);

    }

    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.venueSelectView setFrame:venueFrame];
                         [self.emotionSelectView setFrame:emotionFrame];
                         [self.backButton setFrame:backFrame];
                     }
                     completion:nil];
}

- (IBAction)unwindToEmotion:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Notifications

-(void)displayNotification {
    [self setNotificationForType];

    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:self.notificationTitle subTitle:self.notificationMessage dismissalDelay:2.5 touchHandler:^{
        [self.minimalNotification dismiss];
    }];

    [self.venueSelectView addSubview:self.minimalNotification];

    if ([self.notificationType isEqualToString:@"success"]) {

        [self.minimalNotification setStyle:JFMinimalNotificationStyleSuccess animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:self.selectedImage] animated:YES];
        [self performSelector:@selector(exitToSplash) withObject:self afterDelay:2.0];

    } else if ([self.notificationType isEqualToString:@"error"]) {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleError animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deathSD"]] animated:YES];
    } else {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleWarning animated:YES];
        [self performSelector:@selector(exitToSplash) withObject:self afterDelay:2.0];
    }

    UIFont* titleFont = [UIFont fontWithName:@"BrandonGrotesque-Black" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:16];
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

- (void)exitToSplash {
    [self performSegueWithIdentifier:@"UnwindToSplashFromAdd" sender:self];
}

#pragma mark - refactor stuff




@end
