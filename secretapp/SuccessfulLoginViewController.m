//
//  SuccessfulLoginViewController.m
//  OneNightInBangkok
//
//  Created by John McClelland on 7/6/15.
//  Copyright (c) 2015 machine^n. All rights reserved.
//

#import "SuccessfulLoginViewController.h"

@implementation SuccessfulLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor mintGreenColor];

    self.spinningIntroImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.spinningIntroImageView.image = [UIImage imageNamed:@"leafLarge"];
    self.spinningIntroImageView.center = self.view.center;
    [self.view addSubview:self.spinningIntroImageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.blurEffectView.alpha = 0.0;
    self.blurEffectView.frame = self.view.frame;
    [self.view addSubview:self.blurEffectView];

    [self performSelector:@selector(rotateImageView:) withObject:self.spinningIntroImageView afterDelay:1];
}

- (void)rotateImageView:(UIImageView *)shape {
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 0.4;
    fullRotation.repeatCount = 3;
    [shape.layer addAnimation:fullRotation forKey:@"360"];
    [self performSelector:@selector(expandImageView:) withObject:self.spinningIntroImageView afterDelay:2];
}

- (void)expandImageView:(UIImageView *)shape {
    [UIView animateWithDuration:0.4 animations:^{
        shape.transform = CGAffineTransformMakeScale(2, 2);
        [self addBlurEffect];
    } completion:NULL];
}

- (void)addBlurEffect {
    [UIView animateWithDuration:0.4 animations:^{
        self.blurEffectView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self immediatelyTransition];
    }];
}

- (void)immediatelyTransition {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tabs" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:viewController animated:NO completion:NULL];
}


@end
