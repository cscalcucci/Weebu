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
    [self rotatingColorWheel];
    [self loadEvents];

    //Find location;
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"%@", self.userLocation);

    //Add button
    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:self.emotionLabel];
    [self.view bringSubviewToFront:self.emotionImageView];

    [self performSelector:@selector(expandImageView:) withObject:self.emotionImageView afterDelay:0.05];
    [self performSelector:@selector(rotateImageView:) withObject:self.colorWheel afterDelay:0];

}

#pragma mark - Emotion Calculation

- (void)loadEvents {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"user location for feed: %@", self.userLocation);
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.userLocation.coordinate.latitude
                                                      longitude:self.userLocation.coordinate.longitude];
    
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:[[SettingsService sharedInstance].radius floatValue]];
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
        [self.emotionImageView loadInBackground];
        self.emotionLabel.text = self.emotion.name;
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
    UIColor *color = [UIColor clearColor];
    if (0 < a <= 0.25) {
        color = [UIColor blueEmotionColor];
    }
    if (0.25 < a <= 0.5) {
        color = [UIColor greenEmotionColor];
    }
    if (0.5 < a <= 0.75) {
        color = [UIColor orangeEmotionColor];
    }
    if (0.75 < a <= 1.0) {
        color = [UIColor redEmotionColor];
    }
    return color;
}

- (void)rotatingColorWheel {
    self.colorWheel = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1000, 1000)];
    self.colorWheel.image = [self imageNamed:@"colorWheel" withTintColor:[self createColorFromEmotion:self.emotion]];
    self.colorWheel.center = CGPointMake(self.view.frame.size.width  / 2,
                                        self.view.frame.size.height / 2);
    self.colorWheel.alpha = 0.75;
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
                         shape.transform = CGAffineTransformMakeScale(1.05, 1.05);
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
    fullRotation.repeatCount = 10;
    [shape.layer addAnimation:fullRotation forKey:@"360"];
}

@end
