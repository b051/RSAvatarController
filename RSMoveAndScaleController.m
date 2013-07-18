//
//  RSMoveAndScaleController.m
//
//  Created by Rex Sheng on 5/8/12.
//

#import "RSMoveAndScaleController.h"
#import "UIImage+WithShadow.h"

#define PANEL_HEIGHT 96

@implementation UIView (snapshot)

- (UIImage *)RS_snapshot:(UIEdgeInsets)insets
{
	CALayer *layer = self.layer;
	CGRect rect = UIEdgeInsetsInsetRect(layer.frame, insets);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGPoint vorigin = layer.visibleRect.origin;
	CGContextTranslateCTM(ctx, -vorigin.x - insets.left, -vorigin.y - insets.top);
	[layer renderInContext:ctx];
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return snapshot;
}

@end

@implementation RSMoveAndScaleController
{
	UIImageView *imageView;
	UIView *borderView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.wantsFullScreenLayout = NO;
	self.contentSizeForViewInPopover = CGSizeMake(320, 443);
	self.overlayView.frame = self.view.bounds;
	[self.view addSubview:self.overlayView];
	
	borderView = [[UIView alloc] initWithFrame:self.scrollFrame];
	borderView.clipsToBounds = YES;
	[self.view addSubview:borderView];
	
	UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:borderView.bounds];
	scrollview.showsVerticalScrollIndicator = NO;
	scrollview.showsHorizontalScrollIndicator = NO;
	scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollview.delegate = self;
	[borderView addSubview:scrollview];
	imageView = [[UIImageView alloc] init];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	scrollview.zoomScale = 1.0;
	scrollview.clipsToBounds = NO;
	scrollview.minimumZoomScale = 1.0;
	scrollview.maximumZoomScale = 2.0;
	[scrollview addSubview:imageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}

- (void)cancel
{
	[self.delegate moveAndScaleControllerDidCancel:self];
}

- (CGRect)scrollFrame
{
	CGSize size = self.view.bounds.size;
	CGFloat x = (size.width - _destinationSize.width) / 2;
	CGFloat y = x * 1.5;
	return CGRectMake(x, y, _destinationSize.width, _destinationSize.height);
}

- (void)setDestinationSize:(CGSize)destinationSize
{
	_destinationSize = destinationSize;
	if (self.isViewLoaded) {
		borderView.frame = self.scrollFrame;
	}
}

- (void)choose
{
	CGRect scrollFrame = imageView.superview.frame;
	CGFloat min = MIN(scrollFrame.size.height, scrollFrame.size.width);
	CGFloat x_2 = (scrollFrame.size.width - min) / 2;
	CGFloat y_2 = (scrollFrame.size.height - min) / 2;
	UIImage *snapshot = [imageView.superview RS_snapshot:UIEdgeInsetsMake(y_2, x_2, y_2, x_2)];
	
	if (self.destinationSize.width > 0 && self.destinationSize.height > 0) {
		snapshot = [snapshot resizedImageFitSize:self.destinationSize];
	}
	[self.delegate moveAndScaleController:self didFinishCropping:snapshot];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES];
	[super viewWillAppear:animated];
	imageView.image = _originImage;
	CGFloat height = 320 / _originImage.size.width  * _originImage.size.height;
	_originImage = nil;
	UIScrollView *scrollview = (UIScrollView *)imageView.superview;
	imageView.frame = CGRectMake(0, 0, 320, height);
	scrollview.contentSize = imageView.bounds.size;
	
	CGRect defaultVisible = scrollview.bounds;
	defaultVisible.origin.y = (height - scrollview.bounds.size.height) / 2;
	[scrollview scrollRectToVisible:defaultVisible animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
