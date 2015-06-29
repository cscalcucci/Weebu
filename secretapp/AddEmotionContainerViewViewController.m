//
//  AddEmotionContainerViewViewController.m
//  secretapp
//
//  Created by John McClelland on 6/28/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "AddEmotionContainerViewViewController.h"

@implementation AddEmotionContainerViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    self.venueUrlCall = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&oauth_token=N5Z3YJNLEWD4KIBIOB1C22YOPTPSJSL3NAEXVUMYGJC35FMP&v=20150617", self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude]];
    self.foursquareResults = [NSArray new];
    [self retrieveFoursquareResults];
    NSLog(@"%@", self.userLocation);
}

- (void)retrieveFoursquareResults {
    [FoursquareAPI retrieveFoursquareResults:self.venueUrlCall completion:^(NSArray *array) {
        self.foursquareResults = array;
        NSLog(@"Started call and got %@", array);
        for (FoursquareAPI *item in self.foursquareResults) {
            NSLog(@"%@", item.venueName);
        }
        [self.tableView reloadData];
    }];
}

- (void)setFoursquareResults:(NSArray *)foursquareResults {
    _foursquareResults = foursquareResults;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foursquareResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell"];
    FoursquareAPI *item = [self.foursquareResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", item.venueName];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedLocation" object:[self.foursquareResults objectAtIndex:indexPath.row]];
    self.userLocation = [self.foursquareResults objectAtIndex:indexPath.row];
}

@end
