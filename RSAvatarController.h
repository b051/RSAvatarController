//
//  RSAvatarController.h
//
//  Created by Rex Sheng on 7/6/12.
//

@protocol RSAvatarControllerDelegate <NSObject>

- (void)pickerController:(UIImagePickerController *)picker pickedAvatar:(UIImage *)avatar;
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
