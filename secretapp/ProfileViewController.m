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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    cell.textLabel.text = @"works";
    return cell;
}

#pragma mark - Segue

- (void)onAddEmotionButtonPressed {
    NSLog(@"pressed");
    [self performSegueWithIdentifier:@"ProfileToAdd" sender:self];
    
}

@end
