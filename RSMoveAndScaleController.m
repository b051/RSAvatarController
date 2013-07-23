//
//  RSMoveAndScaleController.m
//
//  Created by Rex Sheng on 5/8/12.
//

#import "RSMoveAndScaleController.h"
#import "UIImage+WithShadow.h"

#define PANEL_HEIGHT 96

@interface RSMoveAndScaleController ()

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation RSMoveAndScaleController
{
	UIImageView *imageView;
	CALayer *scrollLayer;
	UIView *clippingView;
	CGPoint threshold;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		_minimumZoomScale = 1.0;
		_maximumZoomScale = 3.0;
		_destinationSize = CGSizeMake(320, 320);
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = self.foregroundColor;
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
	clippingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - bottomHeight)];
	clippingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	clippingView.clipsToBounds = YES;
	[self.view addSubview:clippingView];
	
	CALayer *mask = [CALayer layer];
	mask.frame = clippingView.frame;
	mask.backgroundColor = (self.foregroundColor ?: [UIColor blackColor]).CGColor;
	scrollLayer = [CALayer layer];
	scrollLayer.backgroundColor = [UIColor whiteColor].CGColor;
	[mask addSublayer:scrollLayer];
	clippingView.layer.mask = mask;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:clippingView.bounds];
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.delegate = self;
	scrollView.zoomScale = 1.0;
	scrollView.clipsToBounds = NO;
	scrollView.minimumZoomScale = _minimumZoomScale;
	scrollView.maximumZoomScale = _maximumZoomScale;
	scrollView.scrollEnabled = YES;
	scrollView.alwaysBounceHorizontal = YES;
	scrollView.alwaysBounceVertical = YES;
	[clippingView addSubview:_scrollView = scrollView];
	
	imageView = [[UIImageView alloc] init];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	[scrollView addSubview:imageView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	scrollLayer.frame = self.scrollFrame;
	if (!imageView.image) {
		imageView.image = _originImage;
		CGFloat width = self.view.bounds.size.width;
		CGFloat height = width / _originImage.size.width  * _originImage.size.height;
		CGPoint origin = scrollLayer.frame.origin;
		CGSize size = CGSizeMake(width, height);
		threshold = CGPointMake((width - self.destinationSize.width) / 2, (height - self.destinationSize.height) / 2);
		imageView.frame = (CGRect){.size = size, .origin.y = origin.y - threshold.y};
		_scrollView.contentSize = size;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat scale = scrollView.zoomScale;
//	NSLog(@"scale=%f offset=%f, %f", scale, scrollView.contentOffset.x, scrollView.contentOffset.y);
	CGPoint offset = scrollView.contentOffset;
	CGSize size = scrollView.contentSize;
	CGPoint t = scale == 1 ? threshold : CGPointMake(threshold.x + size.width * (scale - 1), threshold.y + size.height * (scale - 1));
	offset.y = MAX(MIN(offset.y, t.y), -threshold.y);
	offset.x = MAX(MIN(offset.x, t.x), -threshold.x);
	scrollView.contentOffset = offset;
	scrollView.contentInset = UIEdgeInsetsMake(-offset.y, -offset.x, 0, 0);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	if (scrollView == _scrollView)
		return imageView;
	return nil;
}

- (void)setDestinationSize:(CGSize)destinationSize
{
	_destinationSize = destinationSize;
	if (self.isViewLoaded) {
		scrollLayer.frame = self.scrollFrame;
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
	return UIEdgeInsetsInsetRect(CGRectMake(x, y, _destinationSize.width, _destinationSize.height), self.scrollViewEdgeInsets);
}

- (void)choose
{
	CGRect scrollFrame = scrollLayer.frame;
	CALayer *layer = _scrollView.layer;
	UIGraphicsBeginImageContextWithOptions(self.destinationSize, NO, [UIScreen mainScreen].scale);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGPoint vorigin = layer.visibleRect.origin;
	CGContextTranslateCTM(ctx, -vorigin.x - scrollFrame.origin.x, -vorigin.y - scrollFrame.origin.y);
	[layer renderInContext:ctx];
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[self.delegate moveAndScaleController:self didFinishCropping:snapshot];
}

@end
