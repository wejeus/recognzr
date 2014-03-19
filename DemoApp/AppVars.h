//
//  AppVars.h
//  NNTest
//
//  Created by Samuel Wejéus on 20/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Torch.h"
#import "ImageProcessor.h"

@interface AppVars : NSObject

+ (Torch *)getTorchInstance;
+ (ImageProcessor *)getImageProcessorInstance;

+ (BOOL) preloadObjectInTurns;
+ (void) preloadAllObjects;

@end
