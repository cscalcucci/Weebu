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
#include <math.h>

#import "LocationService.h"
#import "SettingsService.h"
#import "EmotionBubble.h"
#import "Emotion.h"
#import "Event.h"
#import "UIColor+CustomColors.h"

@interface GeneralViewController : UIViewController

@property UIButton *addEmotionButton;
@property CLLocation *userLocation;
@property NSMutableArray *bubbles;
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@property NSNumber *pleasantValue;
@property NSNumber *activatedValue;
@property Emotion *emotion;

@property (weak, nonatomic) IBOutlet PFImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UILabel *emotionLabel;
@property UIImageView *colorWheel;

@end

