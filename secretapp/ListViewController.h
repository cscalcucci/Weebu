//
//  ListViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "LocationService.h"

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property UIButton *addEmotionButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CLLocation *userLocation;

@end
