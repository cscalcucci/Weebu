//
//  ViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "GeneralViewController.h"

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Find location;
    self.userLocation = [LocationService sharedInstance].currentLocation;
    NSLog(@"%@", self.userLocation);

}

- (void)viewWillAppear:(BOOL)animated {
    [self initializeBubbles];

    //Add button
    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Creating bubbles

- (void)initializeBubbles {
    self.bubbles = [NSMutableArray new];
    for (int i = 0; i < 20; i++) {
        int a = arc4random_uniform(self.view.frame.size.width);
        int b = arc4random_uniform(self.view.frame.size.height);
        int c = arc4random_uniform(100);

        EmotionBubble *bubble = [[EmotionBubble alloc] initWithFrame:CGRectMake(a, b, c, c)];
        [bubble setupBubble];
        [bubble bubbleSetup:@"emotion" andInt:i];
        [bubble setTintColor:[UIColor redColor]];
        [self.bubbles addObject:bubble];
        [self.view addSubview:bubble];
        NSLog(@"%i", i);
    }
}

#pragma mark - Floating button

- (UIButton *)createButtonWithTitle:(NSString *)title chooseColor:(UIColor *)color andPosition:(int)position {
    int diameter = 65;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    button.center = CGPointMake(self.view.frame.size.width - position, self.view.frame.size.height - 100);
    button.layer.cornerRadius = button.bounds.size.width / 2;
    button.backgroundColor = color;
    button.layer.borderColor = button.titleLabel.textColor.CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}

#pragma mark - Segue

- (void)onAddEmotionButtonPressed {
    NSLog(@"pressed");
    [self performSegueWithIdentifier:@"GeneralToAdd" sender:self];
    
}

@end
