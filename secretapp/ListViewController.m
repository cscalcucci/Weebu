//
//  ListViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "ListViewController.h"
#import "Emotion.h"
#import "Event.h"
#import "EventTableViewCell.h"

@interface ListViewController ()
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull to Refresh"];
    [self.refreshControl addTarget:self action:@selector(refreshMyTableView:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
//    self.refreshControl = self.refreshControl;

    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - Tableview

-(void)refreshMyTableView:(UIControlEvents *) event {
    NSLog(@"REFRESHING");
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Refreshing the TableView"];
    NSDateFormatter *formattedDate = [[NSDateFormatter alloc]init];
    [formattedDate setDateFormat:@"MMM d, h:mm a"];
    NSString *lastupdated = [NSString stringWithFormat:@"Last Updated on %@",[formattedDate stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:lastupdated];

    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.events) {
//        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
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

-(EventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
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