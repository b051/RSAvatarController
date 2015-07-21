//
//  RSAvatarController.h
//
//  Created by Rex Sheng on 7/6/12.
//

#import <UIKit/UIKit.h>

@protocol RSMoveAndScaleTrait <NSObject>
- (void)cancel;
- (void)choose;
@end

@protocol RSAvatarControllerDelegate;

@interface RSAvatarController : NSObject

- (void)openActionSheetInController:(UIViewController *)viewController withSheetStyle:(UIActionSheetStyle)sheetStyle;
- (void)openActionSheetInController:(UIViewController *)viewController;

@property (nonatomic, readonly) BOOL takingAvatar;
@property (nonatomic, strong, readonly) UIImagePickerController *imagePicker;
@property (nonatomic, weak) id<RSAvatarControllerDelegate> delegate;

@end

@protocol RSAvatarControllerDelegate <UINavigationControllerDelegate>

- (void)avatarController:(RSAvatarController *)controller pickedAvatar:(UIImage *)avatar;
- (UIView *)avatarController:(RSAvatarController *)controller overlayForMoveAndScale:(id<RSMoveAndScaleTrait>)trait;
- (CGRect)popoverRectForAvatarController:(RSAvatarController *)controller;
- (CGSize)destinationImageSizeForAvatarController:(RSAvatarController *)controller;
@optional
- (void)avatarControllerDidCancel:(RSAvatarController *)controller;
- (UIView *)overlayForAvatarControllerImagePicker:(RSAvatarController *)controller;
- (UIViewContentMode)contentModeForAvatarController:(RSAvatarController *)controller;

@end
