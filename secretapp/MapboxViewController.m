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

@property NSNumber *pleasantValue;
@property NSNumber *activatedValue;
@property NSString *emotionImageString;

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

    self.navigationItem.title = @"Map";
    //Nav bar settings
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"BrandonGrotesque-Bold" size:21],
      NSFontAttributeName, nil]];


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

                switch (i) {
                    case 0 ... 500: annotation.subtitle = self.emotion.imageString; NSLog(@"Fizzing"); break;

                    default: annotation.subtitle = @"buzz"; NSLog(@"Buzzing"); break;
                }

                NSLog(@"%@", annotation.subtitle);
                [self.annotationArray addObject:annotation];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"callbackCompleted" object:nil];
        }
    }];
}


-(void)addAnnotations {
    NSLog(@"I got called to add annotations!");
//    NSArray *annotations = [self.annotationArray copy];
    for (RMAnnotation *a in self.annotationArray) {
        NSLog(@"==> %@", a.subtitle);
        [self.mapView addAnnotation:a];
    }
//    [self.mapView addAnnotations:self.annotationArray];
}


-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;

    RMMarker *marker;
    if (annotation.isClusterAnnotation) {
        NSLog(@"I got cluster called");

        marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"circle.png"]];

        if ([self annotationSubTitle:annotation.clusteredAnnotations] != nil) {

            NSString *imageString = [self annotationSubTitle:annotation.clusteredAnnotations];
            marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:imageString]];
        }

        marker.bounds = CGRectMake(0, 0, 50, 50);
        marker.opacity = 0.75;


        // change the size of the circle depending on the cluster's size
        switch ([annotation.clusteredAnnotations count]) {
            case 2: marker.bounds = CGRectMake(0, 0, 40, 40); break;
            case 3: marker.bounds = CGRectMake(0, 0, 45, 45);  break;
            case 4: marker.bounds = CGRectMake(0, 0, 48, 48);  break;
            case 5: marker.bounds = CGRectMake(0, 0, 50, 50);  break;
            case 6 ... 10: marker.bounds = CGRectMake(0, 0, 60, 60);  break;
            case 11 ... 20: marker.bounds = CGRectMake(0, 0, 70, 70);  break;
            case 21 ... 50: marker.bounds = CGRectMake(0, 0, 80, 80);  break;
            default: marker.bounds = CGRectMake(0, 0, 100, 100);  break;
        }

        NSString *clusterLabelContent = [NSString stringWithFormat:@"%lu",
                                         (unsigned long)[annotation.clusteredAnnotations count]];

        CGRect labelSize = [clusterLabelContent boundingRectWithSize:
                            marker.label.frame.size
                                                             options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                        NSFontAttributeName:[UIFont systemFontOfSize:25]
                                                                                                                        }
                                                             context:nil];
        [marker setTextForegroundColor:[UIColor blueColor]];

        UIFont *labelFont = [UIFont systemFontOfSize:25];

        // get the layer's size
        CGSize layerSize = marker.frame.size;

        // calculate its position
        CGPoint position = CGPointMake((layerSize.width - (labelSize.size.width + 10)),
                                       (layerSize.height) / 5);

        // set it all at once
        [marker changeLabelUsingText:clusterLabelContent position:position
                                           font:labelFont foregroundColor:[UIColor blueColor]
                                backgroundColor:[UIColor clearColor]];

    } else {
        NSLog(@"I got single called");

        if (annotation.subtitle != nil) {
            for (Emotion *emotion in self.emotionsArray) {
                if (emotion.imageString == annotation.subtitle) {
                    marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:emotion.imageString]];
                }
            }
        } else {
            marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"circle.png"]];
        }

        marker.bounds = CGRectMake(0, 0, 25, 25);
        marker.canShowCallout = YES;
    }
    return marker;
}

-(NSString *)annotationSubTitle:(NSArray *)cluster {
    NSMutableArray *average = [NSMutableArray new];
    NSString *str;

    for (RMAnnotation *a in cluster) {
        if (a.subtitle != nil) {
            [average addObject:a.subtitle];
        }
    }

    str = [self calculatValuesForArray:average];

    return str;
}

- (NSString *)calculatValuesForArray:(NSArray *)events {
    int count = 0;
    NSNumber *pleasantSum = 0;
    NSNumber *activatedSum = 0;
    Emotion *foundEmote;

    for (NSString *imageString in events) {
        for (Emotion *emotion in self.emotionsArray) {
            if ([imageString isEqualToString: emotion.imageString]) {
                foundEmote = emotion;
            }
        }

        pleasantSum = [NSNumber numberWithFloat:([pleasantSum floatValue] + [foundEmote.pleasantValue floatValue])];
        activatedSum = [NSNumber numberWithFloat:([activatedSum floatValue] + [foundEmote.activatedValue floatValue])];
        count = count + 1;
    }
    self.pleasantValue = [NSNumber numberWithFloat:([pleasantSum floatValue]/count)];
    self.activatedValue = [NSNumber numberWithFloat:([activatedSum floatValue]/count)];
    NSString *returnString = [self findEmotion];
    return returnString;
}

- (NSString*)findEmotion {

    NSString *foundImage = @"circle.png";

    __block NSNumber *distance = [[NSNumber alloc]initWithFloat:100];
        for (Emotion *emotion in self.emotionsArray) {

            NSNumber *x1 = emotion.pleasantValue;
            NSNumber *y1 = emotion.activatedValue;
            NSNumber *newDistance = [NSNumber numberWithFloat:sqrt(pow(([x1 floatValue]-[self.pleasantValue floatValue]), 2.0) + pow(([y1 floatValue]-[self.activatedValue floatValue]), 2.0))];
            if ([newDistance floatValue] < [distance floatValue]) {
                NSLog(@"ASSIGN");
                self.emotion = emotion;
                foundImage = emotion.imageStringWhite;
                distance = newDistance;
            }
        }

    return foundImage;
}


@end
