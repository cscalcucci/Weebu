//
//  DieLabel.m
//  mobilemakers-farkle-v4
//
//  Created by John McClelland on 5/24/15.
//  Copyright (c) 2015 John McClelland. All rights reserved.
//

#import "EmotionBubble.h"
@interface EmotionBubble () /*<ViewControllerDelegate>*/

@end

@implementation EmotionBubble

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setupBubble];
    return self;
}

- (void)setupBubble {
    self.userInteractionEnabled = YES;
    [self programmaticGestureInitializations];
}

- (void)programmaticGestureInitializations {
    //Pan
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pgr];
    //Tap
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tgr];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.viewForBaselineLayout];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.viewForBaselineLayout];
}

- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"tapped!");
    self.isSelected = !self.isSelected;
}

- (void) bubbleSetup:(NSString *)name andInt:(int)number {
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"%@%i", name, number]];
    CGSize imgSize = self.frame.size;

    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    UIImage * resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:resizedImage];
}

@end
