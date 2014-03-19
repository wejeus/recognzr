
#import <UIKit/UIKit.h>
#import "LineDrawingView.h"
#import "Torch.h"
#import "ImageProcessor.h"
#import "AppVars.h"
#import <QuartzCore/QuartzCore.h>

@interface DrawViewController : UIViewController {
    LineDrawingView *drawScreen;
    Torch *torch;
    ImageProcessor *imageProcessor; // why put here instead of @property?
}

- (IBAction)classify:(id)sender;
- (IBAction)reset:(id)sender;

@property (strong, nonatomic) Torch *torch;
@property (strong, nonatomic) ImageProcessor *imageProcessor;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *classifyButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *debugOutput;
@property (weak, nonatomic) IBOutlet UIImageView *drawIcon;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImage;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;

@end
