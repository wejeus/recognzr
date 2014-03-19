
#import "LineDrawingView.h"
#import <QuartzCore/QuartzCore.h> 
@implementation LineDrawingView

BOOL hasData = NO;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.path = [[UIBezierPath alloc] init];
        self.path.lineCapStyle = kCGLineCapRound;
        self.path.miterLimit = 0;
        self.path.lineWidth = 10;
    }
    
    return self;
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    self.path.lineWidth = lineWidth;
}

- (void)drawRect:(CGRect)rect
{
    [self.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [self.path stroke];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    hasData = YES;
    UITouch *mytouch = [[touches allObjects] objectAtIndex:0];
    [self.path moveToPoint:[mytouch locationInView:self]];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [self.path addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.path closePath];
}

-(BOOL) containsData {
    return hasData;
}

-(UIImage *)getUIImage
{
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsBeginImageContext(self.bounds.size);
    
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
}

-(void)reset
{
    hasData = NO;
    [self.path removeAllPoints];
    [self setNeedsDisplay];
}


@end
