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
#import "StandardEventTableViewCell.h"
#import "UIColor+CustomColors.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak,nonatomic) UIButton *logoutButton;
@property (weak,nonatomic) UIButton *shareButton;
@property (nonatomic) UILabel *username;
@property (nonatomic) UILabel *currentMoodLabel;
@property UIVisualEffectView *blueEffectView;
@property UIImageView *currentMood;

@property NSNumber *pleasantValue;
@property NSNumber *activatedValue;
@property Emotion *emotion;

@property MKMapView *mapView;
@property CLLocation *userLocation;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *events;
@property NSArray *emotions;
@property NSMutableArray *recentEvents;
@property PFUser *currentUser;
@property UIRefreshControl *refreshControl;

-(void)refreshMyTableView:(UIControlEvents *) event;

@end
