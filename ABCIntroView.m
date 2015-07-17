//
//  IntroView.m
//  DrawPad
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "ABCIntroView.h"

@interface ABCIntroView () <UIScrollViewDelegate>
@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  UIPageControl *pageControl;

@property UIView *holeView;
@property UIView *circleView;
@property UIButton *doneButton;
@property UIFont *largeFont;
@property UIFont *mediumFont;

@end

@implementation ABCIntroView
//Turn UI variables into instance variables, contribute to open-sourced project
UIImageView *backgroundImageView;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.largeFont = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:30.0];
        self.mediumFont = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:18.0];

        //Rotating hell
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1750, 1750)];
        backgroundImageView.center = CGPointMake(self.frame.size.width, self.frame.size.height);
        backgroundImageView.image = [self imageNamed:@"colorWheel" withTintColor:[UIColor yellowEmotionColor]];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:backgroundImageView];
        [self performSelector:@selector(rotateImageView:) withObject:backgroundImageView afterDelay:0];

        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.8, self.frame.size.width, 10)];
        self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:self.pageControl];
    
        [self createViewOne];
        [self createViewTwo];
        [self createViewThree];
        [self createViewFour];
        
        
        //Done Button
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.85, self.frame.size.width*.8, 60)];
        [self.doneButton setTintColor:[UIColor whiteColor]];
        [self.doneButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
        [self.doneButton.titleLabel setFont:self.mediumFont];
        self.doneButton.backgroundColor = [UIColor redEmotionColor];
        self.doneButton.layer.borderColor = [UIColor redEmotionColor].CGColor;
        [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.doneButton.layer.borderWidth =.5;
        self.doneButton.layer.cornerRadius = 15;
        [self addSubview:self.doneButton];
        
        self.pageControl.numberOfPages = 4;
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width*4, self.scrollView.frame.size.height);
        
        //This is the starting point of the ScrollView
        CGPoint scrollPoint = CGPointMake(0, 0);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    return self;
}

- (void)onFinishedIntroButtonPressed:(id)sender {
    [self.delegate onDoneButtonPressed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
}

#pragma mark - Rotating colorwheel

- (UIImage *)imageNamed:(NSString *) name withTintColor: (UIColor *) tintColor {

    UIImage *baseImage = [UIImage imageNamed:name];
    CGRect drawRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);

    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, drawRect, baseImage.CGImage);

    // draw color atop
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, drawRect);

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

- (void)rotateImageView:(UIImageView *)shape {
    CABasicAnimation *fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 20;
    fullRotation.repeatCount = 100;
    [shape.layer addAnimation:fullRotation forKey:@"360"];
}

#pragma mark - Scrollview views

-(void)createViewOne{
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Welcome to Weebu"];
    titleLabel.font = self.largeFont;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.1, self.frame.size.width*.8, self.frame.size.width)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_One"];
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Anonymous emotion sharing"];
    descriptionLabel.font = self.mediumFont;
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;

    UIImageView *displayImage = [self addImageviewToView:view andEmotionImage:@"emotion4white"];
    [self performSelector:@selector(expandImageView:) withObject:displayImage afterDelay:0.05];

    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
}

-(void)createViewTwo{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth, 0, originWidth, originHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Pick an emotion"];
    titleLabel.font = self.largeFont;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.1, self.frame.size.width*.8, self.frame.size.width)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Two"];
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Tell us how you feel"];
    descriptionLabel.font = self.mediumFont;
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [view addSubview:descriptionLabel];

    for (int i = 1; i <= 20; i++) {
        UIImageView *displayImage = [self addImageviewToView:view andEmotionImage:[NSString stringWithFormat:@"emotion%iwhite", i]];
        int a = arc4random() % 26 + 50;
        displayImage.frame = CGRectMake(0, 0, a, a);
        displayImage.center = CGPointMake((arc4random() % 201) + 100, (arc4random() % 201) + 200);
        [self performSelector:@selector(expandImageView:) withObject:displayImage afterDelay:arc4random_uniform(2)];
    }

    UIImageView *marqueeImage = [self addImageviewToView:view andEmotionImage:@"emotion4white"];
    marqueeImage.frame = CGRectMake(0, 0, 100, 100);
    marqueeImage.center = CGPointMake(self.center.x, self.center.y - 50);
    [self performSelector:@selector(expandImageView:) withObject:marqueeImage afterDelay:0];
    
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

-(void)createViewThree{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*2, 0, originWidth, originHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Explore around you"];
    titleLabel.font = self.largeFont;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.1, self.frame.size.width*.8, self.frame.size.width)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Two"];
    [view addSubview:imageview];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Three"];
    [view addSubview:imageview];
    
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"See the mood of the community"];
    descriptionLabel.font = self.mediumFont;
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;

    UIImageView *displayImage = [self addImageviewToView:view andEmotionImage:@"emotion2white"];
    [self performSelector:@selector(expandImageView:) withObject:displayImage afterDelay:0.05];

    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}


-(void)createViewFour{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*3, 0, originWidth, originHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*.05, self.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Share with friends"];
    titleLabel.font = self.largeFont;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.1, self.frame.size.width*.8, self.frame.size.width)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Two"];
    [view addSubview:imageview];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:@"Intro_Screen_Four"];
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Try it, it's fun!"];
    descriptionLabel.font = self.mediumFont;
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;

    UIImage *sourceImage = [UIImage imageNamed:@"emotion2white"];
    UIImage *flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                scale:sourceImage.scale orientation:UIImageOrientationUpMirrored];

    UIImageView *displayImage1 = [self addImageviewToView:view andEmotionImage:@"emotion2white"];
    displayImage1.image = flippedImage;
    displayImage1.frame = CGRectMake(0, 0, 125, 125);
    displayImage1.center = CGPointMake(view.frame.size.width / 4, self.center.y - 50);
    [self performSelector:@selector(expandImageView:) withObject:displayImage1 afterDelay:0.05];


    UIImageView *displayImage2 = [self addImageviewToView:view andEmotionImage:@"emotion4white"];
    displayImage2.frame = CGRectMake(0, 0, 125, 125);
    displayImage2.center = CGPointMake((view.frame.size.width / 4) * 3, self.center.y - 50);
    [self performSelector:@selector(expandImageView:) withObject:displayImage2 afterDelay:0.25];

    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

#pragma mark - Imageview stuff

- (UIImageView *)addImageviewToView:(UIView *)view andEmotionImage:(NSString *)imageString {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 275, 275)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:imageString];
    imageView.center = CGPointMake(self.center.x, self.center.y - 50);
    [view addSubview:imageView];
    return imageView;
}



- (void)expandImageView:(UIImageView *)shape {
    [UIView animateWithDuration:2.0
                          delay:2.0f
                        options:UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAutoreverse
                     animations:^{
                         shape.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:2.0 animations:^{
                             shape.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

@end