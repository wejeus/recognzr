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
            // we also invert (the 255 - *inp part) image since some idiot (acidentally) trained the network on inverted images..
            [sample setObject:@(255 - *inp) atIndexedSubscript:flatIndex];
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

- (cv::Mat) preprocess:(UIImage *) image {
    
    Mat imageMat1 = [self cvMatFromUIImage:image];
    Mat imageMat = imageMat1.clone();
    
    // measure time
    uint64_t startTime = 0;
    uint64_t endTime = 0;
    uint64_t elapsedTime = 0;
    uint64_t elapsedTimeNano = 0;
    mach_timebase_info_data_t timeBaseInfo;
    mach_timebase_info(&timeBaseInfo);
    startTime = mach_absolute_time();
    


    
//    Mat *processedImage = new Mat(imageMat);
    cvtColor(imageMat, imageMat, CV_BGR2GRAY);

    cv::Rect boundingBox = [self findBoundingBox:imageMat];
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
    resize(finishedFrame, finishedFrame, acceptedSize, 0, 0, cv::INTER_CUBIC);
    
    // measure time
    endTime = mach_absolute_time();
    elapsedTime = endTime - startTime;
    elapsedTimeNano = elapsedTime * timeBaseInfo.numer / timeBaseInfo.denom;
    printf("pre-process time: %f\n", ((float) elapsedTimeNano)/1000000000);
    
    return finishedFrame;
}

-(cv::Rect) findBoundingBox:(Mat &) image {
    std::vector<vector<cv::Point> > contourContainer;
    vector<Vec4i> hierarchy;
    
    // findCountours makes a destructive update, work on a copy
    Mat m = image.clone();
    findContours(m, contourContainer, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_NONE);
    
    // Finds the contour with the largest area
    int area = 0;
    int idx;
    for(int i = 0; i < contourContainer.size(); i++) {
        if(area < contourContainer[i].size())
            idx = i;
    }
    
    cv::Rect boundingBox = cv::boundingRect(contourContainer[idx]);
    return boundingBox;
}

/* WORK IN PROGRESS */
- (cv::Mat) preprocessCamera:(UIImage *)image {
    NSLog(@"preprocessCamera");
    
    // measure time
    uint64_t startTime = 0;
    uint64_t endTime = 0;
    uint64_t elapsedTime = 0;
    uint64_t elapsedTimeNano = 0;
    mach_timebase_info_data_t timeBaseInfo;
    mach_timebase_info(&timeBaseInfo);
    startTime = mach_absolute_time();
    
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
    int widthDiff = boundingBox.width/4.5f;
    int heightDiff = boundingBox.height/4.5f;
    int diff = -1;
    if (widthDiff > heightDiff) {
        diff = widthDiff;
    } else {
        diff = heightDiff;
    }
    
    cv::Mat roi = (imageMat)(boundingBox);
//    cv::Mat *capturedFrame = new Mat();
    cv::Mat finishedFrame;
    cv::copyMakeBorder(roi, finishedFrame, diff, diff, diff, diff, cv::BORDER_CONSTANT, Scalar(255,255,255));


    // convert to correct size
    cv::Size acceptedSize(32,32);
    resize(finishedFrame, finishedFrame, acceptedSize, 0, 0, cv::INTER_CUBIC);
    
    // measure time
    endTime = mach_absolute_time();
    elapsedTime = endTime - startTime;
    elapsedTimeNano = elapsedTime * timeBaseInfo.numer / timeBaseInfo.denom;
    printf("pre-process time: %f\n", ((float) elapsedTimeNano)/1000000000);
    
    return finishedFrame;
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
    CGColorSpaceRelease(colorSpace);
    
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
