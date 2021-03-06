//
//  Emotion.m
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "Emotion.h"
#import <Parse/PFObject+Subclass.h>

@implementation Emotion

@dynamic name;
@dynamic imageFile;
@dynamic imageFileWhite;
@dynamic pleasantValue;
@dynamic activatedValue;
@dynamic imageString;
@dynamic imageStringWhite;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Emotion";
}

@end
