//
//  EpilogueViewController.m
//  BattleShip
//
//  Created by Aaron Johnson on 2017-11-02.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

#import "EpilogueViewController.h"

@interface EpilogueViewController ()

@end

@implementation EpilogueViewController
UIButton *screenButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    screenButton = [[UIButton alloc] initWithFrame:self.view.frame];
    screenButton.backgroundColor = [UIColor colorWithRed:0 green:191 blue:255 alpha:1];
    [screenButton addTarget:self
               action:@selector(buttonPressed)
     forControlEvents:UIControlEventTouchUpInside];
    [screenButton setTitle:@"Thank You For Playing!!!!" forState:UIControlStateNormal];
    [screenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:screenButton];
}
-(void)buttonPressed{
    [self.view.window.rootViewController dismissViewControllerAnimated:true completion:nil];
}

@end
