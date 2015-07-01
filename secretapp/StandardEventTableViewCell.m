//
//  StandardEventTableViewCell.m
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "StandardEventTableViewCell.h"

@implementation StandardEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Animations

- (void)expandImageView:(UIImageView *)shape andActivatedValue:(Emotion *)emotion {
    float a = 2 - (emotion.activatedValue.floatValue/1);
    [UIView animateWithDuration:a
                          delay:a
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse
                     animations:^{
                         shape.transform = CGAffineTransformMakeScale(1.075, 1.075);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:a
                                          animations:^{
                                              shape.transform = CGAffineTransformMakeScale(1, 1);
                                          }];
                     }];
}

@end
