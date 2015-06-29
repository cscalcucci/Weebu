//
//  AddEmotionContainerViewViewController.h
//  secretapp
//
//  Created by John McClelland on 6/28/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "LocationService.h"
#import "FoursquareAPI.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface AddEmotionContainerViewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property CLLocation *userLocation;
@property NSURL *venueUrlCall;
@property (nonatomic) NSArray *foursquareResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
