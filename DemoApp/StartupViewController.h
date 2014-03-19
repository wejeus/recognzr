//
//  StartupViewController.h
//  NNTest
//
//  Created by Samuel Wejéus on 20/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppVars.h"

@interface StartupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic, strong) NSTimer *myTimer;

@end
