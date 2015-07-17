//
//  UserVoiceViewController.m
//  secretapp
//
//  Created by John McClelland on 7/1/15.
//  Copyright (c) 2015 bjc. All rights reserved.
//

#import "UVUserVoiceViewController.h"

@interface UVUserVoiceViewController ()

@end

@implementation UVUserVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UserVoice presentUserVoiceInterfaceForParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
