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
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *venuesButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UIPickerView *emotionPicker;
@property (weak, nonatomic) IBOutlet UIView *venuesContainer;
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

    self.emotionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"emotion10"]];

    self.submitButton.backgroundColor = [UIColor greenColor];
    self.cancelButton.backgroundColor = [UIColor redColor];
    self.venuesButton.backgroundColor = [UIColor
                                            colorWithRed:0.235
                                            green:0.235
                                            blue:0.235
                                            alpha:1];
    CGRect submitFrame = self.submitButton.frame;
    submitFrame.size = CGSizeMake(self.view.frame.size.width, 65);
    self.submitButton.frame = submitFrame;

    self.emotions = [[NSArray alloc]init];
    PFQuery *emotionsQuery = [PFQuery queryWithClassName:@"Emotion"];
    [emotionsQuery orderByAscending:@"createdAt"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        if (!error) {
            self.emotions = emotions;
            [self.emotionPicker reloadAllComponents];
        }
    }];

    self.minimalNotification.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [self.emotionPicker selectRow:10 inComponent:0 animated:YES];
    
    [[LocationService sharedInstance] startUpdatingLocation];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel timeEvent:@"Add emotion"];
}

- (IBAction)onSubmitButtonPressed:(UIButton *)sender {
    [self submitEmotion];
}
- (IBAction)onVenueButtonPressed:(UIButton *)sender {
    [self selectVenue];
}
- (IBAction)onCancelButtonPressed:(UIButton *)sender {
    [self cancelEmotion];
}

#pragma mark - Emotions picker

// SET PICKER FONT SIZE
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    UILabel* tView = (UILabel*)view;
//    if (!tView) {
//        tView = [[UILabel alloc] init];
//        tView.font
//    }
//    return tView;
//}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"Emotions count: %lu", self.emotions.count);
    return self.emotions.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Emotion *emotion = [self.emotions objectAtIndex:row];
    return emotion.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.emotionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"emotion%li",row]];
    self.selectedTag = row;
}


-(void)updateLocation:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[FoursquareAPI class]]) {
        FoursquareAPI *item = [notification object];
        self.selectedItem = [FoursquareAPI new];
        self.selectedItem = item;
        self.venuesButton.titleLabel.text = item.venueName;
        self.containerView.hidden = YES;
        self.didSelectVenue = YES;
    } else {
        NSLog(@"Error Transferring Location Data");
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    //Add code to stop updating location
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

- (void)selectVenue {
    self.venuesContainer.hidden = !self.venuesContainer.hidden;
    if (self.venuesContainer.hidden == NO) {
        [self.view bringSubviewToFront:self.containerView];
    }
}

- (void)cancelEmotion {
    NSLog(@"pressed");
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Add emotion"];

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)unwindToEmotion:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Notifications

-(void)displayNotification {
    [self setNotificationForType];

    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:self.notificationTitle subTitle:self.notificationMessage dismissalDelay:2.5 touchHandler:^{
        [self.minimalNotification dismiss];
    }];

    [self.view addSubview:self.minimalNotification];

    if ([self.notificationType isEqualToString:@"success"]) {

        [self.minimalNotification setStyle:JFMinimalNotificationStyleSuccess animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:self.selectedImage] animated:YES];
        [self performSelector:@selector(cancelEmotion) withObject:self afterDelay:2.0];

    } else if ([self.notificationType isEqualToString:@"error"]) {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleError animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deathSD"]] animated:YES];
    } else {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleWarning animated:YES];
        [self performSelector:@selector(cancelEmotion) withObject:self afterDelay:2.0];
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

@end
