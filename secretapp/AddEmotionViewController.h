//
//  AddEmotionViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "Emotion.h"
#import "Event.h"
#import "LocationService.h"
#import "FoursquareAPI.h"
#import "UIColor+CustomColors.h"

@interface AddEmotionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *selectedEmotionLabel;
@property UIButton *cancelButton;
@property UIButton *addVenue;
@property UIButton *addEmotion;
@property NSArray *emotions;
@property long selectedTag;

@property (weak, nonatomic) IBOutlet UIView *nameView;

@property FoursquareAPI *selectedItem;
@property BOOL didSelectVenue;

@property (weak, nonatomic) IBOutlet UIView *containerView;


@end
