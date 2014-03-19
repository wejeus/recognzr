//
//  CameraViewController.h
//  NNTest
//
//  Created by Samuel Wejéus on 11/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/core/core.hpp>
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/highgui/highgui.hpp>
#import "GLESImageView.h"

using namespace cv;

@class CameraViewController;

@interface CustomCvVideoCamera : CvVideoCamera
- (void)updateOrientation;
- (void)layoutPreviewLayer;
@property (nonatomic, retain) CALayer *customPreviewLayer;
@end

@protocol CameraViewControllerDelegate <NSObject>
@optional
-(void)cameraViewController:(CameraViewController *)cameraViewController didCaptureImage:(cv::Mat) image;
@end

@interface CameraViewController : UIViewController <CvVideoCameraDelegate>

@property (strong) AVCaptureDevice *videoDevice;
@property (nonatomic, retain) CustomCvVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet GLESImageView *imageView;
@property (weak) id<CameraViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;

- (IBAction)captureFrame:(id)sender;
- (IBAction)cancelCapture:(id)sender;
- (IBAction)toggleTorch:(id)sender;

@end
