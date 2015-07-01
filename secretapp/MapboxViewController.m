//
//  MapboxViewController.m
//  secretapp
//
//  Created by Christopher Scalcucci on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "MapboxViewController.h"
#import "Mapbox.h"

#import "LocationService.h"
#import <CoreLocation/CoreLocation.h>

#import <Parse/Parse.h>
#import "Event.h"
#import "Emotion.h"

@interface MapboxViewController () <RMMapViewDelegate>

@property CLLocation *userLocation;
@property RMMapView *mapView;

@property NSMutableArray *annotationArray;
@property NSMutableArray *emotionsArray;
@property NSArray *eventsArray;
@property NSArray *annotations;


@property Event *event;
@property Emotion *emotion;


@end

@implementation MapboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]
                    addObserver:self
                    selector:@selector(addAnnotations)
                    name:@"callbackCompleted"
                    object:nil];

    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoiY3NjYWxjdWNjaSIsImEiOiIyODNmNmFiYTkzZjdlMmMxNWE1MGI4OGEyNmE5MjM3MSJ9.V31zh5rC9gR6B3ec2Wm3vQ"];

    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"cscalcucci.mjji8h23"];

    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds
                                            andTilesource:tileSource];

    self.mapView.delegate = self;

    // Sets Map to View User Location
    self.mapView.showsUserLocation = YES;
    self.mapView.clusteringEnabled = YES;
    [self.mapView setUserTrackingMode:RMUserTrackingModeFollow animated:YES];

    // allows rotation
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;

    // set coordinates
    self.userLocation = [LocationService sharedInstance].currentLocation;
    [[LocationService sharedInstance] startUpdatingLocation];

    // center the map to the coordinates
    [self.mapView setZoom:11 atCoordinate:self.userLocation.coordinate animated:YES];

    [self.view addSubview:self.mapView];
    [self.view bringSubviewToFront:self.mapView];

    [self letThereBeMKAnnotation];

    RMAnnotation *annotation = [[RMAnnotation alloc]
                                     initWithMapView:self.mapView
                                     coordinate:self.mapView.centerCoordinate
                                     andTitle:@"Hello, world!"];
    annotation.userInfo = @"training";


    [self.mapView addAnnotation:annotation];

}

- (void)viewDidAppear:(BOOL)animated {
    self.userLocation = [LocationService sharedInstance].currentLocation;
    [[LocationService sharedInstance] startUpdatingLocation];
    [self.mapView setZoom:11 atCoordinate:self.userLocation.coordinate animated:YES];
}

- (void)letThereBeMKAnnotation {
    PFQuery *query = [Event query];
    [query includeKey:@"emotionObject"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (!error) {
            NSLog(@"Did Run Query");
            self.annotationArray = [[NSMutableArray alloc] init];
            self.emotionsArray = [[NSMutableArray alloc] init];
            self.eventsArray = [[NSArray alloc]initWithArray:events];

            for (int i; i < self.eventsArray.count; i++) {
                self.event = self.eventsArray[i];
                self.emotion = self.event.emotionObject;
                NSLog(@"Emotion %@", self.emotion.imageString);
                [self.emotionsArray addObject:self.emotion];
                [self.event setObject:[NSString stringWithFormat:@"%i", i] forKey:@"indexPath" ];

                CLLocationCoordinate2D annoCoord = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);

                NSLog(@"%f latitude %f longitude", annoCoord.latitude, annoCoord.longitude);

                RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:self.mapView coordinate:annoCoord andTitle:self.emotion.imageString];


//                NSLog(@"%f latitude %f longitude", annotation.coordinate.latitude, annotation.coordinate.longitude);


//            annotation.emotion = self.emotion.imageString;
                [self.annotationArray addObject:annotation];
            }
//            [self.mapView addAnnotations:(NSArray *)[self.annotationArray copy]];


            [[NSNotificationCenter defaultCenter] postNotificationName:@"callbackCompleted" object:nil];
        }
    }];
}


-(void)addAnnotations {
    NSLog(@"I got called to add annotations!");
    NSArray *annotations = [self.annotationArray copy];
    [self.mapView addAnnotations:annotations];
}


-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;

    RMMarker *marker;
    RMMapLayer *layer = nil;

    if (annotation.isClusterAnnotation) {
        NSLog(@"I got cluster called");

        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"emotion16.png"]];
        layer.opacity = 0.75;

        layer.bounds = CGRectMake(0, 0, 50, 50);

        // change the size of the circle depending on the cluster's size
        if ([annotation.clusteredAnnotations count] < 5) {
            NSLog(@"Small");
            layer.bounds = CGRectMake(0, 0, 5, 5);
        } else if (([annotation.clusteredAnnotations count] > 5) && ([annotation.clusteredAnnotations count] < 10)) {
            NSLog(@"Medium");
            layer.bounds = CGRectMake(0, 0, 10, 10);
        } else if (([annotation.clusteredAnnotations count] > 10)) {
            NSLog(@"Large");
            layer.bounds = CGRectMake(0, 0, 30, 30);
        }

        [(RMMarker *)layer changeLabelUsingText:[NSString stringWithFormat:@"%lu",
                                                 (unsigned long)[annotation.clusteredAnnotations count]]];

    } else {
        NSLog(@"I got single called");

        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"emotion1.png"]];
        marker.canShowCallout = YES;

    }


//    if ([annotation.userInfo isEqualToString:@"training"])
//    {
//        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"astronaut1.png"]];
//    }


    return marker;
}


@end
