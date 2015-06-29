//
//  Emotion.h
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>


@interface Emotion : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *name;
@property PFFile *imageFile;
@property NSNumber *pleasantValue;
@property NSNumber *activatedValue;
@property NSString *imageString;
//@property float latitude;
//@property float longitude;

@end
