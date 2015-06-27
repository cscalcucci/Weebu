//
//  SplashViewController.m
//  TheWalls
//
//  Created by John McClelland on 6/14/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "SplashViewController.h"

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstShape =  [self createObjectWithImage:[UIImage imageNamed:@"happy"] andPositions:-85 :0 :65 :65];
    self.secondShape = [self createObjectWithImage:[UIImage imageNamed:@"sad"] andPositions:0 :0 :65 :65];
    self.thirdShape =  [self createObjectWithImage:[UIImage imageNamed:@"silly"] andPositions:85 :0 :65 :65];
}

- (void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(rotateImageView:) withObject:self.firstShape afterDelay:0];
    [self performSelector:@selector(rotateImageView:) withObject:self.secondShape afterDelay:0.2];
    [self performSelector:@selector(expandImageView:) withObject:self.thirdShape afterDelay:0.4];
    [self performSelector:@selector(checkUserThenSegue) withObject:nil afterDelay:2.0];

   

}


- (void)checkUserThenSegue {
    if ([PFUser currentUser] != nil) {
        self.currentUser = [PFUser currentUser];
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        [self presentViewController:viewController animated:NO completion:NULL];
    } else {
        [self performSegueWithIdentifier:@"SplashToSession" sender:self];
    }
}

- (UIImageView *)createObjectWithImage:(UIImage *)image andPositions:(int)x :(int)y :(int)w :(int)h {
    double centerx = self.view.center.x;
    double centery = self.view.center.y;
    UIImageView *object = [[UIImageView alloc]initWithFrame:CGRectMake(centerx + x, centery + y, w, h)];
    object.center = CGPointMake(centerx + x, centery + y);
    object.image = image;
    [self.view addSubview:object];
    return object;
}

- (void)rotateImageView:(UIImageView *)shape {
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 0.4;
    fullRotation.repeatCount = 1;
    [shape.layer addAnimation:fullRotation forKey:@"360"];
}

- (void)expandImageView:(UIImageView *)shape {
    [UIView animateWithDuration:0.4 animations:^{
        shape.transform = CGAffineTransformMakeScale(1.25, 1.25);
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.4 animations:^{
                             shape.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

- (IBAction)unwindToSplash {
    NSLog(@"Unwind");
}

@end
