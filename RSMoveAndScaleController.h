//
//  RSMoveAndScaleController.h
//
//  Created by Rex Sheng on 5/8/12.
//

#import <UIKit/UIKit.h>
#import "RSAvatarController.h"

@class RSMoveAndScaleController;

@protocol RSMoveAndScaleControllerDelegate <NSObject>

- (void)moveAndScaleController:(RSMoveAndScaleController *)moveAndScale didFinishCropping:(UIImage *)destImage;
- (void)moveAndScaleControllerDidCancel:(RSMoveAndScaleController *)moveAndScale;

@end

@interface RSMoveAndScaleController : UIViewController <RSMoveAndScaleTrait, UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic) CGSize destinationSize;
@property (nonatomic, weak) id<RSMoveAndScaleControllerDelegate> delegate;

@end
