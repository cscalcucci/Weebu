//
//  ListViewController.m
//  secretapp
//
//  Created by John McClelland on 6/27/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "ListViewController.h"
#import "Emotion.h"
#import "Event.h"
#import "EventTableViewCell.h"

@interface ListViewController ()
@property PFUser *currentUser;
@property NSArray *events;
@property NSArray *emotions;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.addEmotionButton = [self createButtonWithTitle:@"add" chooseColor:[UIColor redColor] andPosition:50];
    [self.addEmotionButton addTarget:self action:@selector(onAddEmotionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.emotions = [[NSArray alloc]init];
    self.events = [NSArray new];
/*
    PFQuery *emotionsQuery = [PFQuery queryWithClassName:@"Emotion"];
    [emotionsQuery orderByDescending:@"createdAt"];
    [emotionsQuery findObjectsInBackgroundWithBlock:^(NSArray *emotions, NSError *error) {
        if (!error) {
            NSLog(@"%lu", emotions.count);
            self.emotions = emotions;
            Event *event1 = [[Event alloc]init];
            event1.emotionObject = self.emotions[0];
            event1.createdBy = self.currentUser;

            NSLog(@"%@", event1);
            self.events = [[NSArray alloc]initWithObjects:event1, nil];
            [self.tableView reloadData];
        }
    }];
*/
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Event"];
    [eventsQuery orderByDescending:@"createdAt"];
    [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (!error) {
            NSLog(@"%lu", events.count);
            NSLog(@"%@", events.firstObject);

            self.events = events;
        }
    }];
    [self.tableView reloadData];
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
    [self performSegueWithIdentifier:@"ListToAdd" sender:self];
    
}

#pragma mark - Tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

-(EventTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    Event *event = [self.events objectAtIndex:indexPath.row];
    cell.textLabel.text = [event.emotionObject objectForKey:@"name"];
    cell.emotionImageView.file = [event.emotionObject objectForKey:@"imageFile"];

    return cell;
}

@end
