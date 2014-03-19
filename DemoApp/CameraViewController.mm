//
//  CameraViewController.m
//  NNTest
//
//  Created by Samuel Wejéus on 11/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "CameraViewController.h"

// To capture animation
//CATransition *shutterAnimation = [CATransition animation];
//[shutterAnimation setDelegate:self];
//[shutterAnimation setDuration:1.5];
//shutterAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
//[shutterAnimation setType:@"cameraIris"];
//[shutterAnimation setValue:@"cameraIris" forKey:@"cameraIris"];
//[shutterAnimation setRepeatDuration:4.5];
//[[[self.view viewWithTag:90] layer] addAnimation:shutterAnimation forKey:@"cameraIris"];

@interface CameraViewController ()
{
    CustomCvVideoCamera* videoCamera;
    cv::Mat lastCapturedROI; // frame always is dirty with overlays

}

@end

#define LINE_WIDTH 2
#define BOX_X 100
#define BOX_Y 190
#define BOX_SIZE 280

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

cv::Rect captureBounds(0,0,480,640);
cv::Rect outerROIBounds(BOX_X,BOX_Y,BOX_SIZE,BOX_SIZE);
cv::Rect innerROI(BOX_X+LINE_WIDTH, BOX_Y+LINE_WIDTH, BOX_SIZE-(2*LINE_WIDTH), BOX_SIZE-(2*LINE_WIDTH));
cv::Scalar frameColor = cv::Scalar(64, 64, 64);

@implementation CustomCvVideoCamera : CvVideoCamera
- (void)updateOrientation {
    // ignore rotation
//    [self layoutPreviewLayer];
}
//- (void)layoutPreviewLayer;
//{
//    if (self.parentView != nil)
//    {
//        CALayer* layer = self.customPreviewLayer;
//        CGRect bounds = self.customPreviewLayer.bounds;
//        int rotation_angle = 0;
//        
//        switch (defaultAVCaptureVideoOrientation) {
//            case AVCaptureVideoOrientationLandscapeRight:
//                rotation_angle = 180;
//                break;
//            case AVCaptureVideoOrientationPortraitUpsideDown:
//                rotation_angle = 270;
//                break;
//            case AVCaptureVideoOrientationPortrait:
//                rotation_angle = 90;
//            case AVCaptureVideoOrientationLandscapeLeft:
//                break;
//            default:
//                break;
//        }
//        
//        layer.position = CGPointMake(self.parentView.frame.size.width/2., self.parentView.frame.size.height/2.);
//        layer.affineTransform = CGAffineTransformMakeRotation( DEGREES_RADIANS(rotation_angle) );
//        layer.bounds = bounds;
//    }
//}
@end

@implementation CameraViewController

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // TODO
//    2014-03-18 17:14:59.770 symbol-recognizer[808:60b] WARNING: -[<AVCaptureConnection: 0x165bd2d0> isVideoMinFrameDurationSupported] is deprecated.  Please use AVCaptureDevice activeFormat.videoSupportedFrameRateRanges
//    2014-03-18 17:14:59.771 symbol-recognizer[808:60b] WARNING: -[<AVCaptureConnection: 0x165bd2d0> setVideoMinFrameDuration:] is deprecated.  Please use AVCaptureDevice setActiveVideoMinFrameDuration
//    2014-03-18 17:14:59.772 symbol-recognizer[808:60b] WARNING: -[<AVCaptureConnection: 0x165bd2d0> isVideoMaxFrameDurationSupported] is deprecated.  Please use AVCaptureDevice activeFormat.videoSupportedFrameRateRanges
//    2014-03-18 17:14:59.772 symbol-recognizer[808:60b] WARNING: -[<AVCaptureConnection: 0x165bd2d0> setVideoMaxFrameDuration:] is deprecated.  Please use AVCaptureDevice setActiveVideoMaxFrameDuration
    
    self.videoCamera = [[CustomCvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;

    self.videoCamera.delegate = self;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if(!self.videoDevice)
        return;
    [self.videoCamera start];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self configureForTorchMode:AVCaptureTorchModeOff];
    [self.videoCamera stop];
}

- (void)processImage:(Mat&)frame {
    cv::Mat roi = frame(innerROI);
    cv::cvtColor(roi, lastCapturedROI, CV_BGRA2BGR); // this is the possible result to send back to callee
 
    // make area outside ROI a darker, a little hacksy..
    cv::Mat unaffectedROI = roi.clone();
    frame = frame + Scalar(-50,-50,-50);
    unaffectedROI.copyTo(roi);
    cv::rectangle(frame, outerROIBounds, frameColor, LINE_WIDTH, CV_AA);
    
    [self.imageView drawFrame:frame];
}


- (IBAction)captureFrame:(id)sender {
    NSLog(@"capture!");
    
    [self.videoCamera stop]; // make sure opencv dosn't try to put a new frame in the cache we're using.
    
    if ([self.delegate respondsToSelector:@selector(cameraViewController:didCaptureImage:)]) {
        [self.delegate cameraViewController:self didCaptureImage:lastCapturedROI];
    }
    
}

- (IBAction)cancelCapture:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleTorch:(id)sender {
    //Maybe add controls for flash?
    //https://www.cocoacontrols.com/controls/ddexpandablebutton
    
    AVCaptureTorchMode changeToMode = self.torchButton.isSelected? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    [self configureForTorchMode:changeToMode];
}

- (BOOL)configureForTorchMode:(AVCaptureTorchMode)torchMode {
    BOOL result = NO;

    if ([self.videoDevice lockForConfiguration:NULL]) {
        if ([self.videoDevice isTorchModeSupported:torchMode]) {
            self.videoDevice.torchMode = torchMode;
            result = YES;
        }
        self.torchButton.selected = (self.videoDevice.torchMode != AVCaptureTorchModeOff);
        [self.videoDevice unlockForConfiguration];
    }
    
    return result;
}

@end
