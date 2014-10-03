//
//  RSAvatarController.h
//
//  Created by Rex Sheng on 7/6/12.
//

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

/* Supplies the view that will be overlaid atop the selected image as its being moved and scaled.
 This view should include controls (i.e., UIButtons or gesture recognizers) that send "cancel"
 and "choose" messages to the trait object, when the user has canceled or chosen their
 move and scale transformation on the picked image.
 */
- (UIView *)avatarController:(RSAvatarController *)controller overlayForMoveAndScale:(id<RSMoveAndScaleTrait>)trait;

// Returns rect to be used for popover, on iPad
- (CGRect)popoverRectForAvatarController:(RSAvatarController *)controller;

// size to which selected image will be scaled
- (CGSize)destinationImageSizeForAvatarController:(RSAvatarController *)controller;

@optional

// Supplies overlay for the image picker
- (UIView *)overlayForAvatarControllerImagePicker:(RSAvatarController *)controller;

@end
