//
//  LocationService.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol LocationServiceDelegate <NSObject>

- (void)locationServiceDelegate:(CLLocation *)location;

@end

@interface LocationService : NSObject <CLLocationManagerDelegate>

+(LocationService *) sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic, assign) id <LocationServiceDelegate> delegate;

- (void)startUpdatingLocation;

@end
