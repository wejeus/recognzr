//
//  ImageProcessor.h
//  NNTest
//
//  Created by Samuel Wejéus on 18/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
#import <Foundation/Foundation.h>

using namespace cv;

@interface ImageProcessor : NSObject

- (NSMutableArray *) cvMat2MutableArray:(cv::Mat *) mat;
- (int) preprocess:(UIImage *) image toMat:(cv::Mat*)processedImage;
- (int) preprocessCamera:(UIImage *)image toMat:(cv::Mat*)processedImage;
- (Mat) cvMatFromUIImage:(UIImage *)image;
- (UIImage *) UIImageFromCVMat:(Mat)cvMat;

@end
