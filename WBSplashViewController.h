//
//  SplashViewController.h
//  OneNightInBangkok
//
//  Created by John McClelland on 7/5/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "UIColor+CustomColors.h"
#import "LocationService.h"

@interface WBSplashViewController : UIViewController

//UI
@property PFUser *currentUser;

@property UIImageView *firstShape;
@property UIImageView *secondShape;
@property UIImageView *thirdShape;

//Data
@property (nonatomic) NSArray *testArray;

@end
