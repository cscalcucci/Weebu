//
//  DieLabel.h
//  mobilemakers-farkle-v4
//
//  Created by John McClelland on 5/24/15.
//  Copyright (c) 2015 John McClelland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmotionBubble;

@protocol DieLabelDelegate <NSObject>


@end

@interface EmotionBubble : UILabel

@property (nonatomic, assign) id <DieLabelDelegate> delegate;
@property BOOL isSelected;
@property int emotionInt;

- (void)setupBubble;
- (void) bubbleSetup:(NSString *)name andInt:(int)number;


@end
