//
//  StandardEventTableViewCell.h
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "Emotion.h"

@interface WBStandardEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UILabel *emotionName;

@property (weak, nonatomic) IBOutlet UILabel *timeAgo;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UILabel *distanceAway;

- (IBAction)onReportButtonPressed:(id)sender;
- (void)expandImageView:(UIImageView *)shape andActivatedValue:(Emotion *)emotion;

@end
