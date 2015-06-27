//
//  EventTableViewCell.h
//  secretapp
//
//  Created by Bryon Finke on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Emotion.h"

@interface EventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *emotionImageView;

@end
