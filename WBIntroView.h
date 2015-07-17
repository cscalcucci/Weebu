//
//  IntroView.h
//  ABCIntroView
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+CustomColors.h"

@protocol WBIntroViewDelegate <NSObject>

-(void)onDoneButtonPressed;

@end

@interface WBIntroView : UIView
@property id<WBIntroViewDelegate> delegate;

@end
