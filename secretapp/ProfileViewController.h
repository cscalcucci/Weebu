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
#import "SettingsService.h"
#import "Event.h"
#import "EventTableViewCell.h"
#import "StandardEventTableViewCell.h"
#import "UIColor+CustomColors.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property UIButton *addEmotionButton;
@property UIButton *logoutButton;
@property UIButton *shareButton;
@property UILabel *username;
@property UILabel *currentMoodLabel;
@property UIVisualEffectView *blueEffectView;
@property UIImageView *currentMood;


@property MKMapView *mapView;
@property CLLocation *userLocation;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *events;
@property NSArray *emotions;
@property PFUser *currentUser;
@property UIRefreshControl *refreshControl;

-(void)refreshMyTableView:(UIControlEvents *) event;

@end
