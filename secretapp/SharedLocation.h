//
//  Location.h
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SharedLocation : NSObject {
    CLLocation *userLocation;
}

+ (SharedLocation *)sharedLocation;
- (void)setLocation:(CLLocation *)newLocation;
- (CLLocation *)getLocation;

@end
