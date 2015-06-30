//
//  ProfileViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <TwitterKit/TwitterKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "LocationService.h"
#import "UIColor+CustomColors.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property UIButton *addEmotionButton;
@property UIButton *logoutButton;
@property UIButton *shareButton;
@property UILabel *username;
@property UIVisualEffectView *blueEffectView;

@property MKMapView *mapView;
@property CLLocation *userLocation;


@property UIImageView *currentMood;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
