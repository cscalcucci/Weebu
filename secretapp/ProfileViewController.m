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
    [self performSelector:@selector(loadMapDelayBugFix) withObject:nil afterDelay:0.1];

    //Blur
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.blueEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.blueEffectView.alpha = 0.75;

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

    self.shareButton = [self createButtonWithTitle:@"tweet your mood" chooseColor:[UIColor twitterBlueColor] andPosition:0];

    [self.shareButton addTarget:self action:@selector(shareOnTwitter) forControlEvents:UIControlEventTouchUpInside];

    //nav bar title
    self.navigationItem.title = @"Profile";
    //Nav bar settings
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"BrandonGrotesque-Bold" size:21],
      NSFontAttributeName, nil]];
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
            NSLog(@"total events: %i", (int)events.count);
            self.events = events;
            [self.tableView reloadData];
            [self calculatValues];
        }
    }];
}

-(void)loadMapDelayBugFix {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 250)];
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    CLLocationCoordinate2D location = [self.userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 5000, 5000);
    [self.mapView setRegion:region animated:YES];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
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
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    button.center = CGPointMake(self.view.center.x - position, self.view.frame.origin.y + 310);
    button.layer.cornerRadius = 0;
    button.backgroundColor = color;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    button.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:24];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

#pragma mark - Logout button

//- (void)userLogout {
//    NSLog(@"pressed");
//    [PFUser logOutInBackground];
//    [self performSegueWithIdentifier:@"UnwindToSplash" sender:self];
//}

#pragma mark - Twitter share placeholder

- (void)shareOnTwitter {
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    [composer setText:[NSString stringWithFormat:@"My average mood over the past 24 hours was %@.  via @WeebuApp_", self.emotion.name]];
    [composer setImage:[UIImage imageNamed:self.emotion.imageString]];
    self.selectedImage = [UIImage imageNamed:self.emotion.imageString];


    [composer showWithCompletion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
            self.notificationType = [[NSString alloc] initWithFormat:@"error"];
        }
        else {
            NSLog(@"Sending Tweet!");
            self.notificationType = [[NSString alloc] initWithFormat:@"success"];
        }
        [self displayNotification];

    }];
}


#pragma mark - Tableviews

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (StandardEventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:@"StandardEventTableViewCell" owner:self options:nil];
    StandardEventTableViewCell *cell = [objects objectAtIndex:0];
    Event *event = [self.events objectAtIndex:indexPath.row];
    Emotion *emotion = event.emotionObject;
    cell.emotionName.text = emotion.name;
    NSString *imageString = emotion.imageString;

    //Set image
    cell.emotionImageView.image = [UIImage imageNamed:imageString];
    [cell expandImageView:cell.emotionImageView andActivatedValue:emotion];

    //Set time
    cell.timeAgo.text = [self relativeDate:event.createdAt];

    //Caption
    if (event.caption) {
        cell.caption.text = [NSString stringWithFormat:@"%@", event.caption];
    }

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
        if (self.emotion == nil) {
            self.currentMood.image = [UIImage imageNamed:@"emotion10white"];
        } else {
            self.currentMood.image = [UIImage imageNamed:self.emotion.imageString];
        }
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

#pragma mark - Notifications

-(void)displayNotification {
    [self setNotificationForType];

    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:self.notificationTitle subTitle:self.notificationMessage dismissalDelay:2.5 touchHandler:^{
        [self.minimalNotification dismiss];
    }];

    [[[UIApplication sharedApplication] keyWindow] addSubview:self.minimalNotification];

    self.minimalNotification.presentFromTop = YES;
    if ([self.notificationType isEqualToString:@"success"]) {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleSuccess animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:self.selectedImage] animated:YES];
    } else if ([self.notificationType isEqualToString:@"error"]) {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleError animated:YES];
        [self.minimalNotification setLeftAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deathSD"]] animated:YES];
    } else {
        [self.minimalNotification setStyle:JFMinimalNotificationStyleWarning animated:YES];
    }

    UIFont* titleFont = [UIFont fontWithName:@"STHeitiK-Light" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"STHeitiK-Light" size:16];
    [self.minimalNotification setSubTitleFont:subTitleFont];

    [self.minimalNotification presentFromTop];
    [self.minimalNotification show];
}

-(void)setNotificationForType {
    if ([self.notificationType isEqualToString:@"chance"]) {
        self.notificationTitle = [NSString stringWithFormat:@"Watch out!"];
        self.notificationMessage = [NSString stringWithFormat:@"We believe you MIGHT be %@!, but we're onto you!", self.self.emotion.name];

    } else if ([self.notificationType isEqualToString:@"success"]) {
        self.notificationTitle = [NSString stringWithFormat:@"Huzzah!"];
        self.notificationMessage = [NSString stringWithFormat:@"You are now %@!", self.self.emotion.name];

    } else if ([self.notificationType isEqualToString:@"error"]) {
        self.notificationTitle = [NSString stringWithFormat:@"Oh No!"];
        self.notificationMessage = [NSString stringWithFormat:@"You must not be very %@! Try uploading again.", self.emotion.name];
    }
}

@end
