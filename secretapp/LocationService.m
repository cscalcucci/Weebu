//
//  LocationService.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "LocationService.h"

@implementation LocationService

+(LocationService *) sharedInstance
{
    static LocationService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.locationManager = [CLLocationManager new];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (void)startUpdatingLocation {
    NSLog(@"Starting location updates");
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Location service failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray*)locations {
    for (CLLocation *location in locations) {
        NSLog(@"%@", location);
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self reverseGeoCode:locations.firstObject];
            [self.locationManager stopUpdatingLocation];
            self.currentLocation = location;
        }
    }
}

-(void)reverseGeoCode:(CLLocation *)location {
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        self.currentLocation = placemark.location;
        //Setting shared location variable
    }];
}

@end
