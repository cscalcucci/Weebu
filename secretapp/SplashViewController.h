//
//  SplashViewController.h
//  TheWalls
//
//  Created by John McClelland on 6/14/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


#import "LocationService.h"

@interface SplashViewController : UIViewController

@property PFUser *currentUser;

@property UIImageView *firstShape;
@property UIImageView *secondShape;
@property UIImageView *thirdShape;


@end
