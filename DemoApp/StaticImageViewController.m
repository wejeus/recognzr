//
//  StaticImageViewController.m
//  NNTest
//
//  Created by Samuel Wejéus on 12/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "StaticImageViewController.h"

@interface StaticImageViewController ()

@end

@implementation StaticImageViewController

Torch *torch;

//- (id)init
//{
//    self = [super init];
//    
//    if (self) {
//        torch = [[Torch alloc] init];
//        self.imageProcessor = [[ImageProcessor alloc] init];
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    torch = [[Torch alloc] init];
    self.imageProcessor = [[ImageProcessor alloc] init];
}

- (IBAction)button1:(id)sender {
    [self classify:@"custom3_1"];
}

- (IBAction)button2:(id)sender {
    [self classify:@"custom5_1"];
}

- (IBAction)button3:(id)sender {
    [self classify:@"custom8_1"];
}

- (IBAction)button4:(id)sender {
    [self classify:@"custom8_2"];
}

- (void) classify:(NSString *) img
{
    NSString *path = [[NSBundle mainBundle] pathForResource: img ofType: @"png"];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
    
    NSMutableArray *flatImage = [self.imageProcessor preprocess:image];
    int ret = [torch performClassification:flatImage];
    
    self.resultLabel.text = [NSString stringWithFormat:@"%d", ret];
}





@end
