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
	CALayer *scrollLayer;
	UIScrollView *scrollview;
	UIScrollView *clippingView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.contentSizeForViewInPopover = CGSizeMake(320, 443);
	CGRect frame = self.overlayView.frame;
	CGSize size = self.view.bounds.size;
	CGFloat bottomHeight = 96;
	if (frame.size.height < size.height) {
		NSUInteger mask = self.overlayView.autoresizingMask;
		if ((mask | UIViewAutoresizingFlexibleTopMargin) == mask) {
			frame.origin.y = size.height - frame.size.height;
			bottomHeight = frame.size.height;
		}
		self.overlayView.frame = frame;
	} else {
		self.overlayView.frame = self.view.bounds;
	}
	[self.view addSubview:self.overlayView];
	clippingView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - bottomHeight)];
	clippingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	clippingView.clipsToBounds = YES;
	[self.view addSubview:clippingView];

	scrollview = [[UIScrollView alloc] initWithFrame:self.scrollFrame];
	scrollview.showsVerticalScrollIndicator = NO;
	scrollview.showsHorizontalScrollIndicator = NO;
	scrollview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollview.delegate = self;
	[clippingView addSubview:scrollview];
	imageView = [[UIImageView alloc] init];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	scrollview.zoomScale = 1.0;
	scrollview.clipsToBounds = NO;
	scrollview.minimumZoomScale = 0.5;
	scrollview.maximumZoomScale = 2.0;
	[scrollview addSubview:imageView];
	self.view.backgroundColor = self.foregroundColor;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	CALayer *mask = [CALayer layer];
	mask.frame = clippingView.frame;
	mask.backgroundColor = (self.foregroundColor ?: [UIColor blackColor]).CGColor;
	if (!scrollLayer) {
		scrollLayer = [CALayer layer];
		scrollLayer.frame = self.scrollFrame;
		scrollLayer.backgroundColor = [UIColor whiteColor].CGColor;
	}
	scrollview.frame = scrollLayer.frame;
	[mask addSublayer:scrollLayer];
	clippingView.layer.mask = mask;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!imageView.image) {
		imageView.image = _originImage;
		CGFloat width = self.view.bounds.size.width;
		CGFloat height = width / _originImage.size.width  * _originImage.size.height;
		imageView.frame = CGRectMake(0, 0, width, height);
		scrollview.contentSize = imageView.bounds.size;
		
		CGRect defaultVisible = scrollview.bounds;
		defaultVisible.origin.y = (height - scrollview.bounds.size.height) / 2;
		defaultVisible.origin.x = (width - scrollview.bounds.size.height) / 2;
		[scrollview scrollRectToVisible:defaultVisible animated:NO];
	}
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}

- (void)setDestinationSize:(CGSize)destinationSize
{
	_destinationSize = destinationSize;
	if (self.isViewLoaded) {
		scrollLayer.frame = scrollview.frame = self.scrollFrame;
	}
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
