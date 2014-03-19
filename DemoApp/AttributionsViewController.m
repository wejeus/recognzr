
#import "AttributionsViewController.h"

const CGFloat kMargin = 10.f;
const CGFloat kWidth = 320.f;
const CGFloat kParagraphSpacing = 7.f;
const CGFloat kExtraLicenseSpacing = 5.f;


@interface AttributionsViewController ()
@end


@implementation AttributionsViewController


- (NSArray *)readAttributionParagraphs {
    NSString * fileRoot = [[NSBundle mainBundle] pathForResource:@"Attributions" ofType:@"txt"];
    NSString * fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:nil];
    NSArray * lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray * paragraphs = [NSMutableArray array];
    NSMutableString * paragraph = [NSMutableString string];
    
    [paragraphs addObject:@"The following software may be included in this product."];
    
    for (NSString * l in lines) {
        BOOL outputParagraph = NO;
		
        NSString *line = [l stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (paragraph.length > 0) {
            [paragraph appendString:@" "];
        }
        [paragraph appendString:line];
        
        if (line.length == 0) {
            outputParagraph = YES;
        } else if ([line hasPrefix:@"##"]) {
            outputParagraph = YES;
        }
        
        if (outputParagraph && paragraph.length) {
            [paragraphs addObject:[NSString stringWithString:paragraph]];
            [paragraph setString:@""];
        }
    }
    
    return [NSArray arrayWithArray:paragraphs];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"Attributions";
	
	NSArray * paragraphs = [self readAttributionParagraphs];
    CGFloat y = 18.f;
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
    for (NSString * paragraph in paragraphs) {
        UILabel * label = nil;
        BOOL title = NO;
        
        NSString *p = paragraph;
		
        if ([p hasPrefix:@"##"]) {
            title = YES;
            p = [p substringFromIndex:2];
            label = [self createTitleLabel];
        }
		
        if (!label) {
            label = [self createParagraphLabel];
        }
		
        label.text = p;
        
        [self sizeParagraphLabel:label constrainedToWidth:(kWidth - 2.f * kMargin)];
        
        
        if (title) {
            if (y != 0.f) {
                y += kExtraLicenseSpacing;
            }
            label.frame = CGRectMake(kWidth/2.f - label.bounds.size.width/2.f, y, label.bounds.size.width, label.bounds.size.height);
        } else {
            label.frame = CGRectMake(kMargin, y, label.bounds.size.width, label.bounds.size.height);
        }
        
        y += label.bounds.size.height + kParagraphSpacing;
		
        [scrollView addSubview:label];
    }
	
    scrollView.contentSize = CGSizeMake(kWidth, y);
	
    self.view = scrollView;
}


- (UILabel *)createTitleLabel {
    UILabel * label = [[UILabel alloc] init];
    
	label.textColor = [UIColor darkGrayColor];
	label.font = [UIFont boldSystemFontOfSize:17.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    return label;
}


- (UILabel *)createParagraphLabel {
    UILabel * label = [[UILabel alloc] init];
    
	label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14.f];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    return label;
}


- (void)sizeParagraphLabel:(UILabel *)label constrainedToWidth:(CGFloat)width {
    CGRect myLabelFrame = [label frame];
	CGSize myLabelSize = [label.text boundingRectWithSize:CGSizeMake(width, 9999) options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: label.font} context:[NSStringDrawingContext new]].size;
    myLabelFrame.size = myLabelSize;
    [label setFrame:myLabelFrame];
}


@end