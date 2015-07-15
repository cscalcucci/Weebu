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
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;
@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rotatingColorWheel];

    //Nav bar settings
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"BrandonGrotesque-Bold" size:21],
      NSFontAttributeName, nil]];

    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *tempItem = [tabBar.items objectAtIndex:0];
    [tempItem setImage:[self imageWithImage:[UIImage imageNamed:@"icon-temp"] scaledToSize:CGSizeMake(13, 30)]];

    UITabBarItem *listItem = [tabBar.items objectAtIndex:1];
    [listItem setImage:[self imageWithImage:[UIImage imageNamed:@"icon-list"] scaledToSize:CGSizeMake(40.41, 30)]];

    UITabBarItem *addItem = [tabBar.items objectAtIndex:2];
    [addItem setImage:[self imageWithImage:[UIImage imageNamed:@"icon-add"] scaledToSize:CGSizeMake(30, 30)]];

    UITabBarItem *mapItem = [tabBar.items objectAtIndex:3];
    [mapItem setImage:[self imageWithImage:[UIImage imageNamed:@"icon-map"] scaledToSize:CGSizeMake(34.2, 30)]];

    UITabBarItem *profileItem = [tabBar.items objectAtIndex:4];
    [profileItem setImage:[self imageWithImage:[UIImage imageNamed:@"emotion4"] scaledToSize:CGSizeMake(30, 30)]];

    tabBar.tintColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [[LocationService sharedInstance] startUpdatingLocation];
    [self loadEvents];
    [self rotateImageView:self.colorWheel];

    //Blur
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.blurEffectView.alpha = 0;

    self.blurEffectView.frame = self.view.bounds;
    [self.view addSubview:self.blurEffectView];


    //add imageView
    self.emotionImageView = [[PFImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.emotionImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    [self.view addSubview:self.emotionImageView];

    self.userLocation = [LocationService sharedInstance].currentLocation;
    self.venueUrlCall = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&oauth_token=N5Z3YJNLEWD4KIBIOB1C22YOPTPSJSL3NAEXVUMYGJC35FMP&v=20150617", self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude]];
    self.foursquareResults = [NSArray new];
    [self retrieveFoursquareResults];

    [self.view bringSubviewToFront:self.emotionLabel];
    [self.view bringSubviewToFront:self.emotionImageView];

    [self performSelector:@selector(expandImageView:) withObject:self.emotionImageView afterDelay:0.05];
}

- (void)retrieveFoursquareResults {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"LOCATION 1: %@", self.userLocation);
    [FoursquareAPI retrieveFoursquareResults:self.venueUrlCall completion:^(NSArray *array) {
        self.foursquareResults = array;
        NSLog(@"Started call and got %@", array);
        NSLog(@"LOCATION 2: %@", self.userLocation);
        for (FoursquareAPI *item in self.foursquareResults) {
            NSLog(@"VENUE NAME: %@", item.venueName);
        }
        FoursquareAPI *venue = self.foursquareResults.firstObject;
        self.navigationItem.title = [NSString stringWithFormat:@"%@, %@", venue.city, venue.state];
        self.zipLabel.text = [NSString stringWithFormat:@"zipcode: %@",venue.zipcode];
    }];
}

#pragma mark - Emotion Calculation

- (void)loadEvents {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    self.blurEffectView = nil;
    NSLog(@"user location for feed: %@", self.userLocation);
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.userLocation.coordinate.latitude
                                                      longitude:self.userLocation.coordinate.longitude];
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:[[SettingsService sharedInstance].radius floatValue]];
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-72*60*60]; //Time currently set to rolling 3 days, I think
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
    NSLog(@"EVENTS COUNT: %i", (int)self.events.count);
    NSLog(@"RADIUS: %@", [SettingsService sharedInstance].radius);
    for (Event *event in self.events) {
        Emotion *emotion = event.emotionObject;
        pleasantSum = [NSNumber numberWithFloat:([pleasantSum floatValue] + [emotion.pleasantValue floatValue])];
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
                NSLog(@"Distance: %f", [distance floatValue]);

            }
        NSLog(@"EMOTION: %@", self.emotion);
        NSLog(@"EMOTION name: %@", self.emotion.name);
        }

        self.emotionImageView.image = [UIImage imageNamed:self.emotion.imageStringWhite];
        self.emotionLabel.text = self.emotion.name;
        self.emotionLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:48];
        self.colorWheel.image = [self imageNamed:@"colorWheel" withTintColor:[self createColorFromEmotion:self.emotion]];

        [self.view sendSubviewToBack:self.colorWheel];
    }];
}

#pragma mark - Buttons & Views

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

//create color from emotion
- (UIColor*)createColorFromEmotion:(Emotion *)emotion {
    float a = emotion.pleasantValue.floatValue;
    NSLog(@"Emotional pleasant value is %f", a);
    UIColor *color = [UIColor clearColor];
    if (0 < a <= 0.25) {
        color = [UIColor blueEmotionColor];
    } else if (0.25 < a <= 0.5) {
        color = [UIColor greenEmotionColor];
    } else if (0.5 < a <= 0.75) {
        color = [UIColor orangeEmotionColor];
    } else if (0.75 < a <= 1.0) {
        color = [UIColor redEmotionColor];
    }
    NSLog(@"Emotional color is %@", color);
    return color;
}

- (void)rotatingColorWheel {
    self.colorWheel = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1000, 1000)];
    self.colorWheel.center = CGPointMake(self.view.center.x, self.view.center.y - 75);
    self.colorWheel.alpha = 0.6;
    [self.view addSubview:self.colorWheel];
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
                         shape.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:2.0 animations:^{
                             shape.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

- (UIImage *)imageNamed:(NSString *) name withTintColor: (UIColor *) tintColor {

    UIImage *baseImage = [UIImage imageNamed:name];
    CGRect drawRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);

    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, drawRect, baseImage.CGImage);

    // draw color atop
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, drawRect);

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

- (void)rotateImageView:(UIImageView *)shape {
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 10;
    fullRotation.repeatCount = 100;
    [shape.layer addAnimation:fullRotation forKey:@"360"];
}

//repeats, delegate when you have the time
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
