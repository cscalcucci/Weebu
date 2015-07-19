//
//  ListViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "WBListViewController.h"
#import "Emotion.h"
#import "Event.h"
#import "WBStandardEventTableViewCell.h"

@implementation WBListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshMyTableView:)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    self.settingsButton.title = @"";
    UIImage *image = [UIImage imageNamed:@"settings"];
    self.settingsButton.image = image;

    //Navigation bar
    self.navigationItem.title = @"Recent emotions";
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"BrandonGrotesque-Bold" size:21],
      NSFontAttributeName, nil]];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.detailEmotionView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    //Initialize the arrays
    self.emotions = [[NSArray alloc]init];
    self.events = [NSArray new];

    //Instantiate the detail view
    [self createDetailEmotionViewInBackground];

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
            NSLog(@"total events: %lu", (unsigned long)events.count);
            self.events = events;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Tableview

-(void)refreshMyTableView:(UIControlEvents *) event {
    [self.tableView reloadData];

    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.events) {
        return 1;
    } else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

        messageLabel.text = @"Limited data available in your area. Pull down to refresh or adjust account settings.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

-(WBStandardEventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:@"WBStandardEventTableViewCell" owner:self options:nil];
    WBStandardEventTableViewCell *cell =[objects objectAtIndex:0];

    Event *event = [self.events objectAtIndex:indexPath.row];
    Emotion *emotion = event.emotionObject;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.emotionName.text = emotion.name;
    cell.emotionImageView.image = [UIImage imageNamed:emotion.imageString];
    cell.timeAgo.text = [self relativeDate:event.createdAt];
    [cell expandImageView:cell.emotionImageView andActivatedValue:emotion];

    //Caption
    if (event.caption) {
        cell.caption.text = [NSString stringWithFormat:@"%@", event.caption];
    }

    //distance calculation
    PFGeoPoint *parseUserLocation = [PFGeoPoint geoPointWithLocation:self.userLocation];
    NSString *distanceLabel = [NSString new];
    double distance = [parseUserLocation distanceInKilometersTo:event.location];
    if (distance < 0.09) {
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

#pragma mark - Floating button

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    int diameter = 65;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    button.center = CGPointMake(self.view.frame.size.width - position, self.view.frame.size.height - 100);
    button.layer.cornerRadius = button.bounds.size.width / 2;
    button.backgroundColor = color;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

#pragma mark - Segue

- (void)onAddEmotionButtonPressed {
    NSLog(@"pressed");
    [self performSegueWithIdentifier:@"ListToAdd" sender:self];
}

#pragma mark - Detail Emotion

- (void)createDetailEmotionViewInBackground {
    self.detailEmotionView = [[WBDetailEmotionView alloc] initWithFrame:self.view.frame];
    self.detailEmotionView.delegate = self;
    self.detailEmotionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.detailEmotionView];
    [self.view sendSubviewToBack:self.detailEmotionView];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event = [Event new];
    event = [self.events objectAtIndex:indexPath.row];

    self.detailEmotionView.selectedEvent = event;
    [self.detailEmotionView addDetailEmotionWindow:self];
    [self.view bringSubviewToFront:self.detailEmotionView];


    NSLog(@"DETAIL EVENT: %@", self.detailEmotionView.selectedEvent);
    NSLog(@"INDEX PATH: %@", indexPath);
}

- (void)dismissDetailEmotionViewActions {
    [self.detailEmotionView removeFromSuperview];
    [self createDetailEmotionViewInBackground];
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
    //    NSLog(@"%ld year, %ld month, %ld day, %ld hour, %ld minute, %ld second", components.year, components.month, components.day, components.hour, components.minute, (long)components.second);
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