//
//  AppVars.m
//  NNTest
//
//  Created by Samuel Wejéus on 20/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "AppVars.h"

@implementation AppVars

static Torch *mTorch;
static ImageProcessor *mImageProcessor;

+ (Torch *)getTorchInstance
{
    if (mTorch == nil) {
        mTorch = [[Torch alloc] init];
    }
    return mTorch;
}

+ (ImageProcessor *)getImageProcessorInstance
{
    if (mImageProcessor == nil) {
        mImageProcessor = [[ImageProcessor alloc] init];
    }
    return mImageProcessor;
}

+ (BOOL) preloadObjectInTurns
{
    if (mTorch == nil) {
        [self getTorchInstance];
        return YES;
    }
    
    if (mImageProcessor == nil) {
        [self getImageProcessorInstance];
        return YES;
    }
    
    return NO;
}

+ (void) preloadAllObjects
{
    while ([self preloadObjectInTurns]) {
        NSLog(@"object loaded");
    }
}

@end
