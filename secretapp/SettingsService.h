//
//  SettingsService.h
//  secretapp
//
//  Created by Bryon Finke on 6/29/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsService : NSObject

+(SettingsService *) sharedInstance;

@property (strong, nonatomic) NSNumber *radius;
@property (strong, nonatomic) NSString *timeRange;

@end