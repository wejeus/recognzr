
#import <UIKit/UIKit.h>


@interface LineDrawingView : UIView {

}
    
@property (strong, nonatomic) UIBezierPath *path;
@property (nonatomic) CGFloat lineWidth;

-(BOOL) containsData;
-(UIImage *)getUIImage;
-(void)reset;

@end
