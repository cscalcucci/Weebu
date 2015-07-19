//
//  ListViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "WBDetailEmotionView.h"

#import "LocationService.h"
#import "SettingsService.h"
#import "Event.h"

@interface WBListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WBDetailEmotionViewDelegate>

//UI
@property UIButton *addEmotionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Refresh
@property UIRefreshControl *refreshControl;
-(void)refreshMyTableView:(UIControlEvents *) event;

//Delegate
@property WBDetailEmotionView *detailEmotionView;
@property Event *selectedEvent;

//Data
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@property CLLocation *userLocation;

@end
