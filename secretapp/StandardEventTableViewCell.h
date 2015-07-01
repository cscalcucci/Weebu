//
//  StandardEventTableViewCell.h
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Emotion.h"

@interface StandardEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *emotionImageView;
@property (weak, nonatomic) IBOutlet UILabel *emotionName;

@property (weak, nonatomic) IBOutlet UILabel *timeAgo;
@property (weak, nonatomic) IBOutlet UILabel *user_name_here_filler;
@property (weak, nonatomic) IBOutlet UILabel *distanceAway;

- (void)expandImageView:(UIImageView *)shape andActivatedValue:(Emotion *)emotion;

@end
