//
//  GLESImageView.h
//  NNTest
//
//  Created by Samuel Wejéus on 24/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>

using namespace cv;

@interface GLESImageView : UIView

- (void)drawFrame:(const Mat&) bgraFrame;

@end
