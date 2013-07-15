#import <UIKit/UIKit.h>

@interface UIImage (WithShadow)

//- (UIImage *)addShadowSize:(CGSize)shadowSize shadowBlur:(CGFloat)blur shadowColor:(CGColorRef)shadowColor;
//- (UIImage *)addShadowSize:(CGSize)shadowSize shadowBlur:(CGFloat)blur shadowColor:(CGColorRef)shadowColor clippingMask:(CGColorRef)clippingMask;
//- (UIImage *)clippingMask:(CGColorRef)clippingMask;
//- (UIImage*)maskWithMask:(UIImage *)maskImage;
- (UIImage *)blendMode:(CGBlendMode)blendMode color:(CGColorRef)color;
//- (UIImage *)resizedImage:(CGFloat)ratio interpolationQuality:(CGInterpolationQuality)quality orientation:(UIImageOrientation)orientation;

- (UIImage *)blendMode:(CGBlendMode)blendMode image:(CGImageRef)image;
- (UIImage *)blendMode:(CGBlendMode)blendMode color:(CGColorRef)color reverse:(BOOL)reverse;
- (UIImage *)wrap:(UIImage *)newImage;
- (UIImage *)resizedImageFitSize:(CGSize)frameSize;
- (UIImage *)resizedImage:(CGFloat)ratio;
- (UIImage *)clippingMask:(CGColorRef)clippingMask;

@end
