//
//  StartupViewController.m
//  NNTest
//
//  Created by Samuel Wejéus on 20/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "StartupViewController.h"
#import <dispatch/dispatch.h>




@interface StartupViewController ()

@end

@implementation StartupViewController

dispatch_queue_t startupQueue;

//- (id) init {
//    self = [super init];
//    if (self) {
//        startupQueue = dispatch_queue_create("com.bontouch.startupqueue", NULL);
//        NSLog(@"queue created");
////        dispatch_release(startupQueue);
//    }
//    
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    startupQueue = dispatch_queue_create("com.bontouch.startupqueue", NULL);
    
    [self.progressBar setProgress:0.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"TestNotification" object:nil];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(updateUI:) userInfo:nil repeats:NO];
    
    NSLog(@"viewDidLoad done");
    
    UIApplication *app = [UIApplication sharedApplication];
    BOOL flag = app.statusBarHidden;
    NSLog(flag ? @"Yes" : @"No");


}

- (void) receiveTestNotification:(NSNotification *) notification
{
    [self.myTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"launchMainAppView" sender:self];
//    [self presentModalViewController:ViewController animated:NO];
}
- (void)updateUI:(NSTimer *)timer
{
    [self loadObjects];
    
    int numObjects = 3;
    float actual = [self.progressBar progress];
    [self.progressBar setProgress:(actual + 1/(float)numObjects)];
//    [self.progressBar setNeedsDisplay];
    
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(updateUI:) userInfo:nil repeats:NO];
}

- (void) loadObjects {
    
//    id *lastLoadedObject;
    
    dispatch_async(startupQueue, ^(void) {
        if ([AppVars preloadObjectInTurns]) {
            [self.myTimer fire];
            NSLog(@"object loaded");
        } else {
            NSLog(@"all done, launch next");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:self];
        }
    });
    
}

@end
