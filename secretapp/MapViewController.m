//
//  MapViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "MapViewController.h"
#import "FBClusteringManager.h"
#import "FBAnnotationCluster.h"
#import "FBAnnotationClustering.h"
#import "FBQuadTree.h"
#import "SingleAnnotation.h"


@interface MapViewController ()

@property Event *event;
@property Emotion *emotion;
@property FBClusteringManager *clusteringManager;


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
    [[LocationService sharedInstance] startUpdatingLocation];
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
    [query includeKey:@"emotionObject"];
    [query orderByDescending:@"createdAt"];
//    query.limit = 50;
    [query findObjectsInBackgroundWithBlock:^(NSArray *pictures, NSError *error) {
        if (!error) {
        }
        self.annotationArray = [[NSMutableArray alloc] init];
        self.emotionsArray = [[NSMutableArray alloc] init];

        self.eventsArray = [[NSArray alloc]initWithArray:pictures];
        for (int i; i < self.eventsArray.count; i++) {
            self.event = self.eventsArray[i];
            self.emotion = self.event.emotionObject;
            [self.emotionsArray addObject:self.emotion];
            [self.event setObject:[NSString stringWithFormat:@"%i", i] forKey:@"indexPath" ];
            SingleAnnotation *annotation = [SingleAnnotation new];
            annotation.coordinate = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
            annotation.emotion = self.emotion.imageString;
            [self.annotationArray addObject:annotation];
//            [self.mapView addAnnotation:annotation];
        }
        self.clusteringManager = [[FBClusteringManager alloc] initWithAnnotations:self.annotationArray];


    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;

        NSArray *annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];

        [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isEqual:self.mapView.userLocation]) {
        return nil;
    }

    MKAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];

    UIImage *image;
    UIImage *resizedImage;

    if ([annotation isKindOfClass:[FBAnnotationCluster class]]) {

        NSString *imageString = [self calculateValues];
        image = [UIImage imageNamed:imageString];
        resizedImage = [self resizeView:image withSize:@"big"];

    } else if ([annotation isKindOfClass:[SingleAnnotation class]]) {

        NSString *imageString = ((SingleAnnotation*)annotation).emotion;
        image = [UIImage imageNamed:imageString];
        resizedImage = [self resizeView:image withSize:@"small"];

    }
    pin.image = resizedImage;
    pin.canShowCallout =  NO;
    pin.userInteractionEnabled = YES;
    return pin;
}

-(UIImage *)resizeView:(UIImage *)image withSize:(NSString *)size {
    CGSize scaleSize;

    if ([size isEqualToString:@"big"]) {
        scaleSize = CGSizeMake(50.0, 50.0);
    } else {
        scaleSize = CGSizeMake(24.0, 24.0);
    }

    UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

-(void)reverseGeoCode:(CLLocation *)location {
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        self.userLocation = placemark.location;
    }];
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

#pragma mark - Cluster Annotation View Helpers
- (NSString *)calculateValues {
    int count = 0;
    NSNumber *pleasantSum = 0;
    NSNumber *activatedSum = 0;
    for (Event *event in self.eventsArray) {
        Emotion *emotion = event.emotionObject;
        NSLog(@"pleaseValue: %@", emotion.pleasantValue);
        //        int pleasantValue = [[emotion.pleasantValue] intValue];
        pleasantSum = [NSNumber numberWithFloat:([pleasantSum floatValue] + [emotion.pleasantValue floatValue])];
        //        int activatedValue = [[emotion.activatedValue] intValue];
        //        activatedSum = activatedSum + emotion.activatedValue;
        activatedSum = [NSNumber numberWithFloat:([activatedSum floatValue] + [emotion.activatedValue floatValue])];
        count = count + 1;
    }
    NSLog(@"pleasantSum: %f", [pleasantSum floatValue]);
    NSLog(@"activatedSum: %f", [activatedSum floatValue]);
    self.pleasantValue = [NSNumber numberWithFloat:([pleasantSum floatValue]/count)];
    self.activatedValue = [NSNumber numberWithFloat:([activatedSum floatValue]/count)];
    NSLog(@"count: %i", count);
    NSLog(@"pleasntValue: %f", [self.pleasantValue floatValue]);
    NSLog(@"activatedValue: %f", [self.activatedValue floatValue]);
    NSString *emotionString = [NSString stringWithString:[self findEmotion]];
    return emotionString;
}

- (NSString*)findEmotion {
    NSLog(@"finding emotion");
    __block NSNumber *distance = [[NSNumber alloc]initWithFloat:100];
    for (Emotion *emotion in self.emotionsArray) {
        NSNumber *x1 = emotion.pleasantValue;
        NSNumber *y1 = emotion.activatedValue;
        NSNumber *newDistance = [NSNumber numberWithFloat:sqrt(pow(([x1 floatValue]-[self.pleasantValue floatValue]), 2.0) + pow(([y1 floatValue]-[self.activatedValue floatValue]), 2.0))];
        NSLog(@"distance/newDistance: %f/%f", [distance floatValue], [newDistance floatValue]);
        if ([newDistance floatValue] < [distance floatValue]) {
            NSLog(@"ASSIGN");
            self.emotion = emotion;
            distance = newDistance;
        }
        NSLog(@"Distance: %f", [distance floatValue]);
    }
    NSLog(@"EMOTION: %@", self.emotion);
    NSLog(@"EMOTION name: %@", self.emotion.name);
    return self.emotion.imageString;
}



@end
