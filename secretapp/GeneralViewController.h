//
//  ViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "LocationService.h"
#import "EmotionBubble.h"

@interface GeneralViewController : UIViewController

@property UIButton *addEmotionButton;
@property CLLocation *userLocation;

@property NSMutableArray *bubbles;

//@property (weak, nonatomic) IBOutlet EmotionBubble *emotion0;
//@property (weak, nonatomic) IBOutlet EmotionBubble *emotion1;






@end

