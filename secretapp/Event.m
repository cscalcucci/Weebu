//
//  Event.m
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "Event.h"
#import <Parse/PFObject+Subclass.h>

@implementation Event

@dynamic createdBy;
@dynamic emotionObject;
@dynamic location;
@dynamic venueName;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Event";
}

@end
