//
//  SettingsService.m
//  secretapp
//
//  Created by Bryon Finke on 6/29/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "SettingsService.h"

@implementation SettingsService

+(SettingsService *) sharedInstance {
    static SettingsService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.radius = [NSNumber numberWithInt:2];
        self.timeRange = @"one day";
    }
    return self;
}

@end
