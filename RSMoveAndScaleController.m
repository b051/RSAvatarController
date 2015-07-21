//
//  RSMoveAndScaleController.m
//
//  Created by Rex Sheng on 5/8/12.
//

#import "RSMoveAndScaleController.h"
#import <QuartzCore/QuartzCore.h>

@interface RSMoveAndScaleView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) UIViewContentMode minimumContentMode;
@end

@implementation RSMoveAndScaleView
{
	CALayer *mask;
	CALayer *scrollLayer;
	CAShapeLayer *clippingBorder;
	CGPoint threshold;
	CGFloat minimumScale;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		_maximumZoomScale = 3.0;
		_destinationSize = CGSizeMake(320, 320);
		
		mask = [CALayer layer];
		mask.frame = frame;
		mask.backgroundColor = (self.maskForegroundColor ?: [UIColor blackColor]).CGColor;
		scrollLayer = [CALayer layer];
		scrollLayer.backgroundColor = [UIColor whiteColor].CGColor;
		[mask addSublayer:scrollLayer];
		self.layer.mask = mask;
		
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		scrollView.zoomScale = 1.0;
		scrollView.clipsToBounds = NO;
		scrollView.maximumZoomScale = _maximumZoomScale;
		scrollView.scrollEnabled = YES;
		scrollView.alwaysBounceHorizontal = YES;
		scrollView.alwaysBounceVertical = YES;
		scrollView.delegate = self;
		[self addSubview:_scrollView = scrollView];
		
		UIImageView *imageView = [[UIImageView alloc] init];
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		[scrollView addSubview:_imageView = imageView];
		
		clippingBorder = [CAShapeLayer layer];
		clippingBorder.lineWidth = 1;
		clippingBorder.strokeColor = [UIColor whiteColor].CGColor;
		clippingBorder.fillColor = [UIColor clearColor].CGColor;
		[self.layer addSublayer:clippingBorder];
	}
	return self;
}

- (void)dealloc
{
	_scrollView.delegate = nil;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
	_maximumZoomScale = maximumZoomScale;
	_scrollView.maximumZoomScale = maximumZoomScale;
}

- (void)setMaskForegroundColor:(UIColor *)maskForegroundColor
{
	_maskForegroundColor = maskForegroundColor;
	self.backgroundColor = maskForegroundColor;
	self.layer.mask.backgroundColor = (maskForegroundColor ?: [UIColor blackColor]).CGColor;
}

- (void)setMaskBorderColor:(UIColor *)maskBorderColor
{
	_maskBorderColor = maskBorderColor;
	clippingBorder.strokeColor = (maskBorderColor ?: [UIColor whiteColor]).CGColor;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	mask.frame = self.bounds;
	
	CGSize dest = self.destinationSize;
	CGFloat x = roundf((self.bounds.size.width - dest.width) / 2);
	CGFloat y = roundf((self.bounds.size.height - dest.height) / 2);
	CGRect calculated = UIEdgeInsetsInsetRect(CGRectMake(x, y, dest.width, dest.height), self.scrollingViewEdgeInsets);
	scrollLayer.frame = calculated;
	
	clippingBorder.frame = self.bounds;
	clippingBorder.path = [UIBezierPath bezierPathWithRect:calculated].CGPath;
	
	CGSize size = self.imageView.frame.size;
	
	if (size.width > 0 && size.height > 0) {
		CGFloat height = calculated.size.height, width = calculated.size.width;
		CGFloat widthRatio = width / size.width;
		CGFloat heightRatio = height / size.height;
		if (self.minimumContentMode == UIViewContentModeScaleAspectFit) {
			minimumScale = MIN(heightRatio, widthRatio);
		} else {
			minimumScale = MAX(heightRatio, widthRatio);
		}
		size = CGSizeMake(minimumScale * size.width, minimumScale * size.height);
		_scrollView.minimumZoomScale = minimumScale;
		_scrollView.maximumZoomScale = minimumScale * 1.5;
		_scrollView.contentSize = size;
	}
	
	threshold = CGPointMake((size.width - dest.width) / 2, (size.height - dest.height) / 2);
	self.imageView.bounds = (CGRect){.size = size };
	self.imageView.center = self.center;
}

- (void)limitScrollViewInBounds
{
	CGPoint offset = _scrollView.contentOffset;
	CGSize size = _scrollView.contentSize;
	CGFloat scale = 1 - 1 / _scrollView.zoomScale;
	//	NSLog(@"scale %f offset:%@", scale, NSStringFromCGPoint(offset));
	CGPoint t = scale == 1 ? threshold : CGPointMake(threshold.x + size.width * scale, threshold.y + size.height * scale);
	
	offset.y = MAX(MIN(offset.y, t.y), -threshold.y);
	offset.x = MAX(MIN(offset.x, t.x), -threshold.x);
	_scrollView.contentOffset = offset;
	_scrollView.contentInset = UIEdgeInsetsMake(-offset.y, -offset.x, 0, 0);
}

- (void)setDestinationSize:(CGSize)destinationSize
{
	_destinationSize = destinationSize;
	[self setNeedsLayout];
}

- (void)setScrollingViewEdgeInsets:(UIEdgeInsets)scrollingViewEdgeInsets
{
	_scrollingViewEdgeInsets = scrollingViewEdgeInsets;
	[self setNeedsLayout];
}

- (void)setImage:(UIImage *)image
{
	if (self.imageView.image != image) {
		self.imageView.image = image;
		CGFloat width = self.bounds.size.width;
		CGFloat height = width / image.size.width  * image.size.height;
		CGSize size = CGSizeMake(width, height);
		self.imageView.frame = (CGRect){.size = size};
		[self setNeedsLayout];
	}
}

- (UIImage *)croppingImage
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
	return snapshot;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self limitScrollViewInBounds];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

@end


@implementation RSMoveAndScaleController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	if ([self respondsToSelector:@selector(preferredContentSize)]) {
		self.preferredContentSize = CGSizeMake(320, 443);
	} else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		
		self.contentSizeForViewInPopover = CGSizeMake(320, 443);
		
#pragma clang diagnostic pop
	}
	CGSize size = self.view.bounds.size;
	CGRect frame = self.overlayView.frame;
	CGFloat bottomHeight = 96;
	if (frame.size.height > 0 && frame.size.height < size.height) {
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
	
	RSMoveAndScaleView *clippingView = [[RSMoveAndScaleView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - bottomHeight)];
	clippingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	clippingView.minimumContentMode = self.minimumContentMode;
	clippingView.clipsToBounds = YES;
	if (_maximumZoomScale) clippingView.maximumZoomScale = _maximumZoomScale;
	[self.view addSubview:_clippingView = clippingView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_clippingView.destinationSize = _destinationSize;
	_clippingView.image = _originImage;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
	_maximumZoomScale = maximumZoomScale;
	_clippingView.maximumZoomScale = maximumZoomScale;
}

- (void)setMinimumContentMode:(UIViewContentMode)minimumContentMode
{
	_minimumContentMode = minimumContentMode;
	_clippingView.minimumContentMode = minimumContentMode;
}

- (void)setDestinationSize:(CGSize)destinationSize
{
	_destinationSize = destinationSize;
	if (self.isViewLoaded) {
		_clippingView.destinationSize = destinationSize;
	}
}

- (void)cancel
{
	[self.delegate moveAndScaleControllerDidCancel:self];
}

- (void)choose
{
	UIImage *snapshot = [self.clippingView croppingImage];
	[self.delegate moveAndScaleController:self didFinishCropping:snapshot];
}

@end
