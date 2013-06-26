//
//  RSMoveAndScaleController.h
//
//  Created by Rex Sheng on 5/8/12.
//

#import <UIKit/UIKit.h>

@class RSMoveAndScaleController;

@protocol RSMoveAndScaleControllerDelegate <NSObject>

- (void)moveAndScaleController:(RSMoveAndScaleController *)moveAndScale didFinishCropping:(UIImage *)destImage;
- (void)moveAndScaleControllerDidCancel:(RSMoveAndScaleController *)moveAndScale;

@end


@interface RSMoveAndScaleController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic) CGSize destinationSize;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, unsafe_unretained) id<RSMoveAndScaleControllerDelegate> delegate;
- (void)cancel;
- (void)choose;

@end
