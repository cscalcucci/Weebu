//
//  Event.h
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Emotion.h"
#import <Parse/PFObject+Subclass.h>


@interface Event : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property PFUser *createdBy;
@property Emotion *emotionObject;
@property PFGeoPoint *location;
@property NSString *venueName;


@end
