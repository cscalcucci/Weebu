//
//  WBDetailEmotionView.h
//  secretapp
//
//  Created by John McClelland on 7/18/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

#import "UIColor+CustomColors.h"
#import "Emotion.h"
#import "Event.h"
#import "LocationService.h"

@class WBDetailEmotionView;
@protocol WBDetailEmotionViewDelegate <NSObject>

//add methods
- (void)dismissDetailEmotionViewActions;

@end

@interface WBDetailEmotionView : UIView

@property (strong, nonatomic) UIImageView *rotatingColorWheel;
@property Event *selectedEvent;
@property CLLocation *userLocation;

@property id<WBDetailEmotionViewDelegate> delegate;

- (void)addDetailEmotionWindow:(id)sender;

@end
