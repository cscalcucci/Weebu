//
//  WBDetailEmotionView.m
//  secretapp
//
//  Created by John McClelland on 7/18/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "WBDetailEmotionView.h"

@implementation WBDetailEmotionView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"BITCHES!");
        self.userLocation = [LocationService sharedInstance].currentLocation;
    }
    return self;
}

- (void)addDetailEmotionWindow:(id)sender {
    NSLog(@"SUCCESSFULLY CALLED ADD DETAIL EMOTION WINDOW");

    //Add data
    Emotion *emotion = [Emotion new];
    emotion = [self.selectedEvent objectForKey:@"emotionObject"];

    //Add blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurEffectView.alpha = 0;
    blurEffectView.frame = self.frame;
    blurEffectView.center = self.center;
    [self addSubview:blurEffectView];

    //Add color wheel
    self.rotatingColorWheel = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1000, 1000)];
    self.rotatingColorWheel.center = CGPointMake(self.center.x, self.center.y);
    self.rotatingColorWheel.alpha = 0;
    [self addSubview:self.rotatingColorWheel];
    self.rotatingColorWheel.image = [self imageNamed:@"colorWheel" withTintColor:[self createColorFromEmotion:emotion]];
    [self rotateImageView:self.rotatingColorWheel];

    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         blurEffectView.alpha = 0.90;
                         self.rotatingColorWheel.alpha = 0.60;
                     } completion:^(BOOL finished) {
                     }];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * 0.8, self.frame.size.height * 0.65)];
    view.center = self.center;
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 20;
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 5;
    [self addSubview:view];

    UIImageView *emotionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    emotionImage.center = CGPointMake(view.center.x, view.center.y - 200);
    emotionImage.image = [UIImage imageNamed:emotion.imageStringWhite];
    [self addSubview:emotionImage];

    UILabel *emotionName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    emotionName.center = CGPointMake(view.center.x, view.center.y - 100);
    emotionName.textAlignment = NSTextAlignmentCenter;
    emotionName.text = [NSString stringWithFormat:@"%@",emotion.name];
    emotionName.font = [UIFont fontWithName:@"BrandonGrotesque-Black" size:24];
    [self addSubview:emotionName];

    UILabel *emotionCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    emotionCaption.center = CGPointMake(view.center.x, view.center.y - 50);
    emotionCaption.textAlignment = NSTextAlignmentCenter;
    emotionCaption.text = [NSString stringWithFormat:@"\"\%@\"",self.selectedEvent.caption];
    emotionCaption.font = [UIFont fontWithName:@"BrandonGrotesque-Black" size:24];
    if (self.selectedEvent.caption.length == 0) {
    } else {
        [self addSubview:emotionCaption];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissDetailEmotionView)];
    [blurEffectView addGestureRecognizer:tap];

    //Distance
    PFGeoPoint *parseUserLocation = [PFGeoPoint geoPointWithLocation:self.userLocation];
    NSString *distanceLabel = [NSString new];
    double distance = [parseUserLocation distanceInKilometersTo:self.selectedEvent.location];
    if (distance < 0.09) {
        distanceLabel = [NSString stringWithFormat:@"%im", (int)(distance * 1000)];
        NSLog(@"%@", distanceLabel);
    } else if (distance < 1.0) {
        distanceLabel = [NSString stringWithFormat:@"%.1fm", distance * 1000];
        NSLog(@"%@", distanceLabel);
    } else {
        distanceLabel = [NSString stringWithFormat:@"%.1fmi",distance / 0.621371192];
    }

    //Date & User
    NSString *timeLabel = [[NSString alloc] initWithString:[self relativeDate:self.selectedEvent.createdAt]];
    PFUser *user = [PFUser currentUser];


    UITextView *hilariousText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width * 0.9, view.frame.size.height / 3)];
    hilariousText.text = [NSString stringWithFormat:@"About %@ ago, %@ was feeling %@.  This took place %@ from where you are.", timeLabel, user.username, emotion.name, distanceLabel];
    hilariousText.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:24];
    hilariousText.userInteractionEnabled = NO;
    hilariousText.center = CGPointMake(view.center.x, view.center.y + 50);
    [hilariousText sizeToFit];
    [self addSubview:hilariousText];
}

- (void)dismissDetailEmotionView {
    NSLog(@"DISMISS DETAIL EMOTION VIEW");
    [self.delegate dismissDetailEmotionViewActions];
}

#pragma mark - Rotating Colorwheel Methods

//Create color from emotion
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

//Customize colorwheel color, a useful method to change a black png to something cooler
- (UIImage *)imageNamed:(NSString *) name withTintColor: (UIColor *) tintColor {

    UIImage *baseImage = [UIImage imageNamed:name];
    CGRect drawRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);

    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    //Draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, drawRect, baseImage.CGImage);

    //Draw color atop
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

#pragma mark - Utility Methods

- (NSString *)relativeDate:(NSDate *)dateCreated {
    NSCalendarUnit units = NSCalendarUnitSecond |
    NSCalendarUnitMinute | NSCalendarUnitHour |
    NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;

    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:dateCreated
                                                                     toDate:[NSDate date]
                                                                    options:0];
    //    NSLog(@"%ld year, %ld month, %ld day, %ld hour, %ld minute, %ld second", components.year, components.month, components.day, components.hour, components.minute, (long)components.second);
    if (components.year > 0) {
        if (components.year == 1) {
            return [NSString stringWithFormat:@"%ldyr", (long)components.year];
        } else {
            return [NSString stringWithFormat:@"%ldyrs", (long)components.year];
        }
    } else if (components.month > 0) {
        if (components.month == 1) {
            return [NSString stringWithFormat:@"%ldmo", (long)components.month];
        } else {
            return [NSString stringWithFormat:@"%ldmo", (long)components.month];
        }
    } else if (components.weekOfYear > 0) {
        if (components.weekOfYear == 1) {
            return [NSString stringWithFormat:@"%ldwk", (long)components.weekOfYear];
        } else {
            return [NSString stringWithFormat:@"%ldwks", (long)components.weekOfYear];
        }
    } else if (components.day > 0) {
        if (components.day == 1) {
            return [NSString stringWithFormat:@"%ldd", (long)components.day];
        } else {
            return [NSString stringWithFormat:@"%ldd", (long)components.day];
        }
    } else if (components.hour > 0) {
        if (components.hour == 1) {
            return [NSString stringWithFormat:@"%ldhr", (long)components.hour];
        } else {
            return [NSString stringWithFormat:@"%ldhrs", (long)components.hour];
        }
    } else if (components.minute > 0) {
        if (components.year == 1) {
            return [NSString stringWithFormat:@"%ldmin", (long)components.minute];
        } else {
            return [NSString stringWithFormat:@"%ldmin", (long)components.minute];
        }
    } else if (components.second > 0) {
        if (components.second == 1) {
            return [NSString stringWithFormat:@"%ldsec", (long)components.second];
        } else {
            return [NSString stringWithFormat:@"%ldsec", (long)components.second];
        }
    } else {
        return [NSString stringWithFormat:@"Time Traveller"];
    }
}

@end
