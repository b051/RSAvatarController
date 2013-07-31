//
//  RSMoveAndScaleController.h
//
//  Created by Rex Sheng on 5/8/12.
//

#import <UIKit/UIKit.h>
#import "RSAvatarController.h"

@interface RSMoveAndScaleView : UIView

@property (nonatomic) CGSize destinationSize UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets scrollingViewEdgeInsets UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat maximumZoomScale UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *maskForegroundColor UI_APPEARANCE_SELECTOR;

@end


@protocol RSMoveAndScaleControllerDelegate;

@interface RSMoveAndScaleController : UIViewController <RSMoveAndScaleTrait, UIScrollViewDelegate>

@property (nonatomic, strong, readonly) RSMoveAndScaleView *clippingView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic) CGFloat maximumZoomScale;
@property (nonatomic) UIViewContentMode minimumContentMode; // you can only set it to UIViewContentModeScaleAspectFit or UIViewContentModeScaleAspectFill. Default to UIViewContentModeScaleAspectFit

@property (nonatomic, weak) id<RSMoveAndScaleControllerDelegate> delegate;
@property (nonatomic) CGSize destinationSize;

@end

@protocol RSMoveAndScaleControllerDelegate <NSObject>

- (void)moveAndScaleController:(RSMoveAndScaleController *)moveAndScale didFinishCropping:(UIImage *)destImage;
- (void)moveAndScaleControllerDidCancel:(RSMoveAndScaleController *)moveAndScale;

@end
