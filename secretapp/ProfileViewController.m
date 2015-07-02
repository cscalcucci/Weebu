//
//  ProfileViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Map
    self.userLocation = [LocationService sharedInstance].currentLocation;
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 250)];
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    CLLocationCoordinate2D location = [self.userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 5000, 5000);
    [self.mapView setRegion:region animated:YES];
    [self.view addSubview:self.mapView];

    //Blur
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blueEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.blueEffectView.alpha = 1.0;

    self.blueEffectView.frame = self.view.bounds;
    [self.view addSubview:self.blueEffectView];

    //Add blank view to put buttons on
    UIView *blankBar = [[UIView alloc]initWithFrame:CGRectMake(0, 280, self.view.frame.size.width, 60)];
    blankBar.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:blankBar];

    //Username
    self.username = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
    self.username.center = CGPointMake(self.view.frame.size.width / 2, 225);
    self.username.text = [PFUser currentUser].username;
    self.username.textAlignment = NSTextAlignmentCenter;
    self.username.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:24];
    [self.view addSubview:self.username];

    //bringing tableview in front of map
    [self.view bringSubviewToFront:self.tableView];

    //buttons
    self.logoutButton = [self createButtonWithTitle:@"logout" chooseColor:[UIColor redEmotionColor] andPosition:-100];
    [self.logoutButton addTarget:self action:@selector(userLogout) forControlEvents:UIControlEventTouchUpInside];

    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor greenEmotionColor] andPosition:0];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.shareButton = [self createButtonWithTitle:@"share" chooseColor:[UIColor blueEmotionColor] andPosition:100];
    [self.shareButton addTarget:self action:@selector(shareOnTwitter) forControlEvents:UIControlEventTouchUpInside];

    //nav bar title
    self.navigationItem.title = @"Profile";
}

- (void)viewDidAppear:(BOOL)animated {
    [self resetStatus];
    self.emotions = [[NSArray alloc]init];
    self.events = [NSArray new];

    self.userLocation = [LocationService sharedInstance].currentLocation;
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.userLocation.coordinate.latitude
                                                      longitude:self.userLocation.coordinate.longitude];

    //Pulling only events for current user
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles: [[SettingsService sharedInstance].radius floatValue]];
    [eventsQuery whereKey:@"createdBy" equalTo:[PFUser currentUser]];
    [eventsQuery includeKey:@"createdBy"];
    [eventsQuery includeKey:@"emotionObject"];
    [eventsQuery orderByDescending:@"createdAt"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (!error) {
            NSLog(@"total events: %lu", events.count);
            self.events = events;
            [self.tableView reloadData];
            [self calculatValues];
        }
    }];
}

-(void)refreshMyTableView:(UIControlEvents *) event {
    [self.tableView reloadData];

    [self.refreshControl endRefreshing];
}

-(void)resetStatus {
    //should add a feature in shared services that detects whether or not
    self.currentMood.image = nil;
    self.currentMoodLabel.text = nil;
}

#pragma mark - Floating button

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 60)];
    button.center = CGPointMake(self.view.center.x - position, self.view.frame.origin.y + 310);
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

    [composer setText:[NSString stringWithFormat:@"My average mood over the past 24 hours was %@.  via @WeebuApp_", self.emotion.name]];
    [composer setImage:[UIImage imageNamed:self.emotion.imageString]];

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

    //Set image
    cell.emotionImageView.image = [UIImage imageNamed:imageString];
    [cell expandImageView:cell.emotionImageView andActivatedValue:emotion];

    //Set time
    cell.timeAgo.text = [self relativeDate:event.createdAt];

    //user info
    PFUser *user = event.createdBy;
    cell.user_name_here_filler.text = [NSString stringWithFormat:@"%@", user.email];

    //distance calculation
    PFGeoPoint *parseUserLocation = [PFGeoPoint geoPointWithLocation:self.userLocation];
    NSString *distanceLabel = [NSString new];
    double distance = [parseUserLocation distanceInKilometersTo:event.location];
    if (distance < 0.1) {
        distanceLabel = [NSString stringWithFormat:@"%im", (int)(distance * 1000)];
        NSLog(@"%@", distanceLabel);
    } else if (distance < 1.0) {
        distanceLabel = [NSString stringWithFormat:@"%.1fm", distance * 1000];
        NSLog(@"%@", distanceLabel);
    } else {
        distanceLabel = [NSString stringWithFormat:@"%.1fmi",distance / 0.621371192];
    }
    cell.distanceAway.text = distanceLabel;

    return cell;
}

#pragma mark - Das Algorithm

- (void)calculatValues {
    //Date for 24 hours
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-24*60*60];
    self.recentEvents = [NSMutableArray new];
    int count = 0;
    NSNumber *pleasantSum = 0;
    NSNumber *activatedSum = 0;

    //Only add recent events
    for (Event *event in self.events) {
        if (event.createdAt > date) {
            [self.recentEvents addObject:event];
        }
    }

    for (Event *event in self.recentEvents) {
        Emotion *emotion = event.emotionObject;
        pleasantSum = [NSNumber numberWithFloat:([pleasantSum floatValue] + [emotion.pleasantValue floatValue])];
        activatedSum = [NSNumber numberWithFloat:([activatedSum floatValue] + [emotion.activatedValue floatValue])];
        count = count + 1;
    }

    self.pleasantValue = [NSNumber numberWithFloat:([pleasantSum floatValue]/count)];
    self.activatedValue = [NSNumber numberWithFloat:([activatedSum floatValue]/count)];
    [self findEmotion];
}

- (void)findEmotion {
    NSLog(@"finding emotion");
    __block NSNumber *distance = [[NSNumber alloc]initWithFloat:100];
    PFQuery *emotionsQuery = [PFQuery queryWithClassName:@"Emotion"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        for (Emotion *emotion in emotions) {
            NSNumber *x1 = emotion.pleasantValue;
            NSNumber *y1 = emotion.activatedValue;
            NSNumber *newDistance = [NSNumber numberWithFloat:sqrt(pow(([x1 floatValue]-[self.pleasantValue floatValue]), 2.0) + pow(([y1 floatValue]-[self.activatedValue floatValue]), 2.0))];
            if ([newDistance floatValue] < [distance floatValue]) {
                self.emotion = emotion;
                distance = newDistance;
            }
        }

        //Current mood imageview
        self.currentMood = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.currentMood.center = CGPointMake(self.view.frame.size.width / 2, 150);
        self.currentMood.image = [UIImage imageNamed:self.emotion.imageString];
        self.currentMood.layer.cornerRadius = 100 / 2;
        self.currentMood.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.currentMood];

        //Current mood label
        self.currentMoodLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 25)];
        self.currentMoodLabel.center = CGPointMake(self.view.frame.size.width / 2, 250);
        self.currentMoodLabel.text = self.emotion.name;
        self.currentMoodLabel.textAlignment = NSTextAlignmentCenter;
        self.currentMoodLabel.font = [UIFont fontWithName:@"BrandonGrotesque-MediumItalic" size:17];
        [self.view addSubview:self.currentMoodLabel];
    }];
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
            return [NSString stringWithFormat:@"%ldmin", (long)components.minute];
        } else {
            return [NSString stringWithFormat:@"%ldmin", (long)components.minute];
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
