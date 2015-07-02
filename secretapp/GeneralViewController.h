//
//  ViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ParseUI/ParseUI.h>
#import "FoursquareAPI.h"
#include <math.h>

#import "LocationService.h"
#import "SettingsService.h"
#import "EmotionBubble.h"
#import "Emotion.h"
#import "Event.h"
#import "UIColor+CustomColors.h"

@interface GeneralViewController : UIViewController

@property (weak, nonatomic) UIButton *addEmotionButton;
@property CLLocation *userLocation;
@property NSMutableArray *bubbles;
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@property NSNumber *pleasantValue;
@property NSNumber *activatedValue;
@property Emotion *emotion;
@property (nonatomic) UIVisualEffectView *blurEffectView;

@property NSURL *venueUrlCall;
@property (nonatomic) NSArray *foursquareResults;

@property (strong, nonatomic) UIImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UILabel *emotionLabel;
@property (strong, nonatomic) UIImageView *colorWheel;
@property (weak, nonatomic) UIColor *selectedEmotionColor;

@end

