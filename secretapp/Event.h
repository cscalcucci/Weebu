//
//  Event.h
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Event : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *createdBy;
@property PFObject *emotionObject;
@property PFGeoPoint *location;

@end
