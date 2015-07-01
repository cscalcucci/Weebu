//
//  ProfileViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Map
    self.userLocation = [LocationService sharedInstance].currentLocation;
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    CLLocationCoordinate2D location = [self.userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 5000, 5000);
    [self.mapView setRegion:region animated:YES];
    [self.view addSubview:self.mapView];

    //Blur
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.blueEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.blueEffectView.alpha = 0.5;

    self.blueEffectView.frame = self.view.bounds;
    [self.view addSubview:self.blueEffectView];

    //Current mood
    self.currentMood = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.currentMood.center = CGPointMake((self.view.frame.size.width  / 3) - 50, 150);
    self.currentMood.image = [UIImage imageNamed:@"emotion0"];
    self.currentMood.layer.cornerRadius = 100 / 2;
    self.currentMood.backgroundColor = [UIColor redEmotionColor];
    [self.view addSubview:self.currentMood];

    //Username
    self.username = [[UILabel alloc]initWithFrame:CGRectMake(200, 125, 100, 50)];
    self.username.backgroundColor = [UIColor yellowEmotionColor];
    self.username.text = [PFUser currentUser].username;
    [self.view addSubview:self.username];

    //Current mood label
    self.currentMoodLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 200, 100, 50)];
    self.currentMoodLabel.backgroundColor = [UIColor yellowEmotionColor];
    self.currentMoodLabel.text = @"current mood";
    [self.view addSubview:self.currentMoodLabel];

    //bringing tableview in front of map
    [self.view bringSubviewToFront:self.tableView];

    //buttons
    self.logoutButton = [self createButtonWithTitle:@"logout" chooseColor:[UIColor redEmotionColor] andPosition:50];
    [self.logoutButton addTarget:self action:@selector(userLogout) forControlEvents:UIControlEventTouchUpInside];

    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor greenEmotionColor] andPosition:125];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.shareButton = [self createButtonWithTitle:@"share" chooseColor:[UIColor blueEmotionColor] andPosition:200];
    [self.shareButton addTarget:self action:@selector(shareOnTwitter) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewDidAppear:(BOOL)animated {
    self.emotions = [[NSArray alloc]init];
    self.events = [NSArray new];

    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"user location for feed: %@", self.userLocation);
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.userLocation.coordinate.latitude
                                                      longitude:self.userLocation.coordinate.longitude];

    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles: [[SettingsService sharedInstance].radius floatValue]];
    [eventsQuery includeKey:@"createdBy"];
    [eventsQuery includeKey:@"emotionObject"];
    [eventsQuery orderByDescending:@"createdAt"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (!error) {
            NSLog(@"total events: %lu", events.count);
            NSLog(@"%@", events.firstObject);
            self.events = events;
            [self.tableView reloadData];
        }
    }];
}

-(void)refreshMyTableView:(UIControlEvents *) event {
    [self.tableView reloadData];

    [self.refreshControl endRefreshing];
}

#pragma mark - Floating button

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 35)];
    button.center = CGPointMake(self.view.frame.size.width - position, self.view.frame.origin.y + 100);
    button.layer.cornerRadius = 7.5;
    button.backgroundColor = color;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

#pragma mark - Logout button

- (void)userLogout {
    NSLog(@"pressed");
    [PFUser logOutInBackground];
    [self performSegueWithIdentifier:@"UnwindToSplash" sender:self];
}

#pragma mark - Twitter share placeholder

- (void)shareOnTwitter {
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    [composer setText:@"just setting up my weebu"];
    [composer setImage:[UIImage imageNamed:@"happy"]];

    [composer showWithCompletion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

#pragma mark - Tableviews

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (StandardEventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *objects=[[NSBundle mainBundle]loadNibNamed:@"StandardEventTableViewCell" owner:self options:nil];
    StandardEventTableViewCell *cell =[objects objectAtIndex:0];
    Event *event = [self.events objectAtIndex:indexPath.row];
    Emotion *emotion = event.emotionObject;
    cell.emotionName.text = emotion.name;
    NSString *imageString = emotion.imageString;
    cell.emotionImageView.image = [UIImage imageNamed:imageString];
    [cell expandImageView:cell.emotionImageView andActivatedValue:emotion];
    cell.timeAgo.text = [self relativeDate:event.createdAt];
    PFUser *user = event.createdBy;
    cell.user_name_here_filler.text = [NSString stringWithFormat:@"%@", user.email];
    return cell;
}

#pragma mark - Segue

- (void)onAddEmotionButtonPressed {
    NSLog(@"pressed");
    [self performSegueWithIdentifier:@"ProfileToAdd" sender:self];
    
}

#pragma mark - Utility Methods

- (NSString *)relativeDate:(NSDate *)dateCreated {
    NSCalendarUnit units = NSCalendarUnitSecond |
    NSCalendarUnitMinute | NSCalendarUnitHour |
    NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:dateCreated
                                                                     toDate:[NSDate date]
                                                                    options:0];
    if (components.year > 0) {
        if (components.year == 1) {
            return [NSString stringWithFormat:@"%ldyr", (long)components.year];
        } else {
            return [NSString stringWithFormat:@"%ldyrs", (long)components.year];
        }
    } else if (components.month > 0) {
        if (components.month == 1) {
            return [NSString stringWithFormat:@"%ldmo", (long)components.month];
        } else {
            return [NSString stringWithFormat:@"%ldmo", (long)components.month];
        }
    } else if (components.weekOfYear > 0) {
        if (components.weekOfYear == 1) {
            return [NSString stringWithFormat:@"%ldwk", (long)components.weekOfYear];
        } else {
            return [NSString stringWithFormat:@"%ldwks", (long)components.weekOfYear];
        }
    } else if (components.day > 0) {
        if (components.day == 1) {
            return [NSString stringWithFormat:@"%ldd", (long)components.day];
        } else {
            return [NSString stringWithFormat:@"%ldd", (long)components.day];
        }
    } else if (components.hour > 0) {
        if (components.hour == 1) {
            return [NSString stringWithFormat:@"%ldhr", (long)components.hour];
        } else {
            return [NSString stringWithFormat:@"%ldhrs", (long)components.hour];
        }
    } else if (components.minute > 0) {
        if (components.year == 1) {
            return [NSString stringWithFormat:@"%ldm", (long)components.minute];
        } else {
            return [NSString stringWithFormat:@"%ldm", (long)components.minute];
        }
    } else if (components.second > 0) {
        if (components.second == 1) {
            return [NSString stringWithFormat:@"%ldsec", (long)components.second];
        } else {
            return [NSString stringWithFormat:@"%ldsec", (long)components.second];
        }
    } else {
        return [NSString stringWithFormat:@"Time Traveller"];
    }
}

@end
