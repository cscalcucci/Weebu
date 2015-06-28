//
//  MapViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView = [[MKMapView alloc]initWithFrame:self.view.frame];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    self.centerMap = [self createCenterMapButton];
    [self.centerMap addTarget:self action:@selector(didTapCenterMapButton:) forControlEvents:UIControlEventTouchUpInside];

    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewDidAppear:(BOOL)animated {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"%@", self.userLocation);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (self.locationCallAmt == 1) {
        CLLocationCoordinate2D location = [userLocation coordinate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 10000, 10000);
        [self.mapView setRegion:region animated:YES];
    }
    self.locationCallAmt++;
}

#pragma mark - Buttons

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

-(UIButton *)createCenterMapButton {

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - 175, 30, 30)];

    UIImage *image = [UIImage imageNamed:@"icon-location"];
    CGSize scaleSize = CGSizeMake(10.0, 10.0);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    button.layer.cornerRadius = button.bounds.size.width / 2;
    button.backgroundColor = [UIColor blueEmotionColor];
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    [button setImage:resizedImage forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

#pragma mark - Button actions

- (void)onAddEmotionButtonPressed {
    NSLog(@"pressed");
    [self performSegueWithIdentifier:@"MapToAdd" sender:self];
}

-(void)didTapCenterMapButton:(id)sender{
    [[LocationService sharedInstance] startUpdatingLocation];
    self.userLocation = [LocationService sharedInstance].currentLocation;
    CLLocationCoordinate2D location = self.userLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 10000, 10000);
    [self.mapView setRegion:region animated:YES];
}

@end
