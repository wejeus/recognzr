//
//  ImageProcessor.m
//  NNTest
//
//  Created by Samuel Wejéus on 18/07/2013.
//  Copyright (c) 2013 Samuel Wejéus. All rights reserved.
//

#import "ImageProcessor.h"
#import <mach/mach_time.h>

@implementation ImageProcessor


- (NSMutableArray *) cvMat2MutableArray:(cv::Mat *) mat
{
    NSMutableArray *sample = [[NSMutableArray alloc] initWithCapacity:1024];
    
    int flatIndex = 0;
    for (int row = 0; row < mat->rows; ++row) {
        
        unsigned char* inp  = mat->ptr<unsigned char>(row); // check this if correct type!
        
        for (int col = 0; col < mat->cols; ++col) {
            [sample setObject:@(255 - *inp) atIndexedSubscript:flatIndex]; // training was preformed on inverted grayscale images -> convert to match
            *inp++;
            flatIndex++;
        }
    }
    
    return sample;
}

-(void) saveImage:(cv::Mat *) mat {
    UIImage *img = [self UIImageFromCVMat:*mat];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
}

uint64_t getUptimeInNanoseconds() {
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    return mach_absolute_time() * s_timebase_info.numer / s_timebase_info.denom;
}

// Preprocess for handdrawn sample
- (int) preprocess:(UIImage *) image toMat:(cv::Mat*)processedImage {
    
    Mat imageMat1 = [self cvMatFromUIImage:image];
    Mat imageMat = imageMat1.clone();
    
    // measure time
    uint64_t start = getUptimeInNanoseconds();
    
    cvtColor(imageMat, imageMat, CV_BGR2GRAY);

    cv::Rect boundingBox = [self findBoundingBox:imageMat];
    if (boundingBox.area() == 0) {
        return 1;
    }
    
    int widthDiff = boundingBox.width/4.5f;
    int heightDiff = boundingBox.height/4.5f;
    int diff = -1;
    if (widthDiff > heightDiff) {
        diff = widthDiff;
    } else {
        diff = heightDiff;
    }
    
    cv::Mat roi = (imageMat)(boundingBox);
    cv::Mat finishedFrame;
    cv::copyMakeBorder(roi, finishedFrame, diff, diff, diff, diff, cv::BORDER_CONSTANT, Scalar(255,255,255));

    // convert to correct size
    cv::Size acceptedSize(32,32);
    resize(finishedFrame, *processedImage, acceptedSize, 0, 0, cv::INTER_CUBIC);
    
    // measure time
    uint64_t end = getUptimeInNanoseconds();
    uint64_t elapsedTimeMilli = end - start;
    printf("pre-process time: %f\n", ((float) elapsedTimeMilli)/(1000*1000*1000));
    
    return 0;
}

// If nothing no good candidate is found return Rect with area 0
-(cv::Rect) findBoundingBox:(Mat &) image {
    std::vector<vector<cv::Point> > contourContainer;
    vector<Vec4i> hierarchy;
    
    // findCountours makes a destructive update, work on a copy
    Mat m = image.clone();
    findContours(m, contourContainer, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_NONE);
    
    if (contourContainer.size() == 0) {
        NSLog(@"Could not find any bounding box!");
        return cv::Rect(0,0,0,0);
    }
    
    // Finds the contour with the largest area
    int area = 0;
    int idx = 0;
    for(int i = 0; i < contourContainer.size(); i++) {
        if(area < contourContainer[i].size())
            idx = i;
    }
    
    cv::Rect boundingBox = cv::boundingRect(contourContainer[idx]);
    return boundingBox;
}

// Preprocess for sample captured from camera
/* WORK IN PROGRESS */
- (int) preprocessCamera:(UIImage *)image toMat:(cv::Mat*)processedImage {
    NSLog(@"preprocessCamera");
    
    // measure time
    uint64_t start = getUptimeInNanoseconds();
    
    Mat imageMat = [self cvMatFromUIImage:image];
    
    cvtColor(imageMat, imageMat, CV_BGR2GRAY);
    GaussianBlur(imageMat, imageMat, cv::Size(5,5), 1);
    threshold(imageMat, imageMat, 120, 255, THRESH_BINARY);
    
    int erosion_type = MORPH_CROSS; // MORPH_RECT, MORPH_CROSS, MORPH_ELLIPSE
    int erosion_size = 5;
    Mat erosionElement = getStructuringElement(erosion_type, cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ), cv::Point( erosion_size, erosion_size ) );
    
    // Apply the erosion operation
    erode(imageMat, imageMat, erosionElement);

    cv::Rect boundingBox = [self findBoundingBox:imageMat];
    if (boundingBox.area() == 0) {
        return 1;
    }
    
    int widthDiff = boundingBox.width/4.5f;
    int heightDiff = boundingBox.height/4.5f;
    int diff = -1;
    if (widthDiff > heightDiff) {
        diff = widthDiff;
    } else {
        diff = heightDiff;
    }
    
    cv::Mat roi = (imageMat)(boundingBox);
    cv::Mat finishedFrame;
    cv::copyMakeBorder(roi, finishedFrame, diff, diff, diff, diff, cv::BORDER_CONSTANT, Scalar(255,255,255));

    // convert to correct size
    cv::Size acceptedSize(32,32);
    resize(finishedFrame, *processedImage, acceptedSize, 0, 0, cv::INTER_CUBIC);
    
    // measure time
    uint64_t end = getUptimeInNanoseconds();
    uint64_t elapsedTimeMilli = end - start;
    printf("pre-process time: %f\n", ((float) elapsedTimeMilli)/(1000*1000*1000));
    
    return 0;
}


-(Mat) cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *) UIImageFromCVMat:(Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
