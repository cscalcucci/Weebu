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
    [self letThereBeMKAnnotation];

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

#pragma mark - Map stuff

- (void)letThereBeMKAnnotation {
    PFQuery *query = [Event query];
    [query orderByDescending:@"createdAt"];
    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *pictures, NSError *error) {
        if (!error) {
        }
        self.annotationArray = [[NSMutableArray alloc] init];
        self.objectArray = [[NSArray alloc]initWithArray:pictures];
        for (int i; i < self.objectArray.count; i++) {
            Event *event = self.objectArray[i];
            [event setObject:[NSString stringWithFormat:@"%i", i] forKey:@"indexPath" ];
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = CLLocationCoordinate2DMake(event.location.latitude, event.location.longitude);
            [self.annotationArray addObject:annotation];
            [self.mapView addAnnotation:annotation];
        }
    }];
}

-(void)reverseGeoCode:(CLLocation *)location {
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        self.userLocation = placemark.location;
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isEqual:self.mapView.userLocation]) {
        return nil;
    }
    MKAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    int randomNumber = arc4random_uniform(3)+1;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"emotion%i",randomNumber]];

    CGSize scaleSize = CGSizeMake(24.0, 24.0);
    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    pin.image = resizedImage;
    pin.canShowCallout =  NO;
    pin.userInteractionEnabled = YES;
    return pin;
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
