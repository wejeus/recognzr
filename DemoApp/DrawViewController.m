//
//  DrawViewController.m
//  NNTest
//
//  Created by Samuel Wejéus on 17/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "DrawViewController.h"
#import "CameraViewController.h"
#import <mach/mach_time.h>

@interface DrawViewController () <CameraViewControllerDelegate>
    
@end

@implementation DrawViewController

#define DRAW_VIEW 1
#define CAMERA_VIEW 2
#define RESULT_VIEW 3

BOOL useCameraImage = NO;
BOOL isShowingResultView = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    self.title = @"Recognzr";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"w: %f h: %f", screenWidth, screenHeight);

    drawScreen = [[LineDrawingView alloc] initWithFrame:CGRectMake(0, 119, 320, 299)];

    self.borderLabel.layer.borderColor = [[UIColor alloc] initWithRed:0.2824 green:0.2824 blue:0.2824 alpha:1].CGColor;
    self.borderLabel.layer.borderWidth = 2.0f;
    
    [self.view addSubview:drawScreen];
    
    // Load classifier
    self.torch = [AppVars getTorchInstance];
    self.imageProcessor = [AppVars getImageProcessorInstance];
    
    // Style the buttons
    UIImage *buttonImage = [[UIImage imageNamed:@"blackButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [self.classifyButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.classifyButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.resetButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.resetButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [self.view bringSubviewToFront:self.drawIcon];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
}

#define __STDC_FORMAT_MACROS
#include <inttypes.h>

- (IBAction)classify:(id)sender {
    if (isShowingResultView && !useCameraImage) {
        return;
    }
    
    UIImage *image;
    NSMutableArray *flatImage;
    int err = 0;
    
    if (useCameraImage) {
        image = [self.cameraImage image];
        
        cv::Mat mat;
//        for (int i = 0; i < 10; ++i) {
            err = [self.imageProcessor preprocessCamera:image toMat:&mat];
            flatImage = [self.imageProcessor cvMat2MutableArray:&mat];
//        }
        
        //debug
        [self.cameraImage setImage:[self.imageProcessor UIImageFromCVMat:mat]];
    } else {
        if (![drawScreen containsData]) {
            return;
        }
        
        image = [drawScreen getUIImage];
        
        cv::Mat mat;
//        for (int i = 0; i < 10; ++i) {
            err = [self.imageProcessor preprocess:image toMat:&mat];
            flatImage = [self.imageProcessor cvMat2MutableArray:&mat];
//        }
    }

    // Add fade in/out animation
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.6;
    [self.resultLabel.layer addAnimation:animation forKey:nil];
    
    int determinedClass = -1;
    if (!err) {
        for (int i = 0; i < 10; ++i) {

            uint64_t start = getUptimeInNanoseconds2(); // for measure time
        
            determinedClass = [self.torch performClassification:flatImage];
            
            // for measure time
            uint64_t end = getUptimeInNanoseconds2();
            uint64_t elapsedTimeMilli = end - start;
            printf("classification time: %f\n", ((float) elapsedTimeMilli)/(1000*1000*1000));
        }
    }
    
    NSLog(@"result: %d", determinedClass);

    [self showView:RESULT_VIEW];
    
    if (err) {
        self.resultLabel.text = [NSString stringWithFormat:@"%@", @"?"];
    } else {
        self.resultLabel.text = [NSString stringWithFormat:@"%d", determinedClass];
    }

    [drawScreen reset];
    useCameraImage = NO;

//    [self useDebugData:flatImage result:ret];
}

uint64_t getUptimeInNanoseconds2() {
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    return mach_absolute_time() * s_timebase_info.numer / s_timebase_info.denom;
}

- (void) useDebugData:(NSMutableArray *) flatImage result:(int)res {
    NSMutableArray *debug = [self.torch getDebugPrediction:flatImage];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setMaximumFractionDigits:2];
//    [formatter setMinimumFractionDigits:1];
//    [formatter setMaximumSignificantDigits:1];
//    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    [formatter setDecimalSeparator:@"."];
    
//    int index = 0;
//    for (NSObject * obj in debug) {
//        if ([obj isKindOfClass:[NSNumber class]]) {
//            NSString *value = [formatter stringFromNumber:obj];
//            [result appendString:[NSString stringWithFormat:@"%d:", index]];
//            [result appendString:value];
//            [result appendString:@"  "];
//        } else {
//            [result appendString:@"err"];
//        }
//        
//        if ((index % 5) == 0) {
//            printf("newline");
//            [result appendString:@"\n"];
//        }
//        index++;
//    }
    
//    self.debugOutput.text = result;
    
//    if ([[debug objectAtIndex:res] doubleValue] < 0.1f) {
//        self.resultLabel.text = [NSString stringWithFormat:@"?"];
//    }
}

- (void) showView:(int) view {
    self.resultLabel.hidden = YES;
    self.cameraImage.hidden  = YES;
    drawScreen.hidden = YES;
    self.resultLabel.hidden = YES;
    
    if (view == CAMERA_VIEW) {
        self.cameraImage.hidden = NO;
    } else if (view == RESULT_VIEW) {
        self.resultLabel.hidden = NO;
        isShowingResultView = YES;
    } else {
        drawScreen.hidden = NO;
    }
}

- (IBAction)reset:(id)sender {
    [drawScreen reset];
    self.resultLabel.text = @"";
    useCameraImage = NO;
    [self showView:DRAW_VIEW];
    isShowingResultView = NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue");
    if ([segue.destinationViewController isKindOfClass:[CameraViewController class]]) {
        ((CameraViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - CameraViewControllerDelegate

-(void)cameraViewController:(CameraViewController *)cameraViewController didCaptureImage:(cv::Mat)image {
    NSLog(@"didCaptureImage");
    [self showView:CAMERA_VIEW];
    useCameraImage = YES;
    
    UIImage *im = [self.imageProcessor UIImageFromCVMat:image];
    [self.cameraImage setImage:im];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
