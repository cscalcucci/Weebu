//
//  StandardEventTableViewCell.m
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "WBStandardEventTableViewCell.h"

@implementation WBStandardEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Animations

- (IBAction)onReportButtonPressed:(id)sender {
    //Alert user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh noes." message:@"We'll look into the post.  Thanks for letting us know!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

    //Contact mission control
    PFObject *report = [PFObject objectWithClassName:@"Report"];
    report[@"createdBy"] = [PFUser currentUser];
    [report saveInBackground];

    return;
}

- (void)expandImageView:(UIImageView *)shape andActivatedValue:(Emotion *)emotion {
    float a = 5;
    [UIView animateWithDuration:a
                          delay:arc4random_uniform(2)
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse
                     animations:^{
                         shape.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:a
                                          animations:^{
                                              shape.transform = CGAffineTransformMakeScale(1, 1);
                                          }];
                     }];
}

@end
