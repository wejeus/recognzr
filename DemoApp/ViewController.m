//
//  ViewController.m
//  NNTest
//
//  Created by Samuel Wejéus on 09/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    
    DBTileButton *button = [[DBTileButton alloc] initWithFrame:CGRectMake(109.0f, 60.0f, 178.0f, 154.0f)];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"Draw" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    How do you do delegation to different scenes?
//    ViewController *destination = [segue destinationViewController];
//    destination.customString = @"Arrived from Scene 1";
//    [self.navigationController pushViewController:destination ];

}

-(IBAction)backToMainView:(UIStoryboardSegue *)segue {

}

@end
