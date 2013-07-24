//
//  RSAvatarController.h
//
//  Created by Rex Sheng on 7/6/12.
//

@protocol RSMoveAndScaleTrait <NSObject>
- (void)cancel;
- (void)choose;
@end

@protocol RSAvatarControllerDelegate <UINavigationControllerDelegate>
- (void)pickerController:(UIImagePickerController *)picker pickedAvatar:(UIImage *)avatar;
- (UIView *)overlayForMoveAndScale:(id<RSMoveAndScaleTrait>)trait;
- (CGRect)rectForAvatarPopover;
- (CGSize)destImageSize;
@optional
- (UIView *)overlayForImagePicker:(UIImagePickerController *)imagePicker;
@end

@interface RSAvatarController : NSObject
- (void)openActionSheetInController:(UIViewController *)viewController withSheetStyle:(UIActionSheetStyle)sheetStyle;
- (void)openActionSheetInController:(UIViewController *)viewController;
@property (nonatomic, readonly) BOOL takingAvatar;
@property (nonatomic, strong, readonly) UIImagePickerController *imagePicker;
@property (nonatomic, weak) id<RSAvatarControllerDelegate> delegate;
@end
