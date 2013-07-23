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
	UIScrollView *scrollView;
	UIScrollView *clippingView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_minimumZoomScale = 1.0;
		_maximumZoomScale = 3.0;
	}
	return self;
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

	scrollView = [[UIScrollView alloc] initWithFrame:self.scrollFrame];
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.delegate = self;
	[clippingView addSubview:scrollView];
	imageView = [[UIImageView alloc] init];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	scrollView.zoomScale = 1.0;
	scrollView.clipsToBounds = NO;
	scrollView.minimumZoomScale = _minimumZoomScale;
	scrollView.maximumZoomScale = _maximumZoomScale;
	[scrollView addSubview:imageView];
	self.view.backgroundColor = self.foregroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	CALayer *mask = [CALayer layer];
	mask.frame = clippingView.frame;
	mask.backgroundColor = (self.foregroundColor ?: [UIColor blackColor]).CGColor;
	if (!scrollLayer) {
		scrollLayer = [CALayer layer];
		scrollLayer.frame = self.scrollFrame;
		scrollLayer.backgroundColor = [UIColor whiteColor].CGColor;
	}
	scrollView.frame = scrollLayer.frame;
	[mask addSublayer:scrollLayer];
	clippingView.layer.mask = mask;
	if (!imageView.image) {
		imageView.image = _originImage;
		CGFloat width = self.view.bounds.size.width;
		CGFloat height = width / _originImage.size.width  * _originImage.size.height;
		imageView.frame = CGRectMake(0, 0, width, height);
		scrollView.contentSize = imageView.bounds.size;
		
		CGRect defaultVisible = scrollView.bounds;
		defaultVisible.origin.y = (height - scrollView.bounds.size.height) / 2;
		defaultVisible.origin.x = (width - scrollView.bounds.size.height) / 2;
		[scrollView scrollRectToVisible:defaultVisible animated:NO];
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
		scrollLayer.frame = scrollView.frame = self.scrollFrame;
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
	CGRect scrollFrame = scrollView.frame;
	CGFloat min = MIN(scrollFrame.size.height, scrollFrame.size.width);
	CGFloat x_2 = (scrollFrame.size.width - min) / 2;
	CGFloat y_2 = (scrollFrame.size.height - min) / 2;
	UIImage *snapshot = [scrollView RS_snapshot:UIEdgeInsetsMake(y_2, x_2, y_2, x_2)];
	
	if (self.destinationSize.width > 0 && self.destinationSize.height > 0) {
		snapshot = [snapshot resizedImageFitSize:self.destinationSize];
	}
	[self.delegate moveAndScaleController:self didFinishCropping:snapshot];
}

@end
