//
//  MapViewController.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#import "LocationService.h"
#import "Event.h"
#import "Emotion.h"
#import "UIColor+CustomColors.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property UIButton *addEmotionButton;
@property UIButton *centerMap;

@property CLLocation *userLocation;
@property MKMapView *mapView;

@property NSInteger locationCallAmt;
@property NSInteger indexPath;

@property NSArray *objectArray;
@property NSMutableArray *annotationArray;


@end
