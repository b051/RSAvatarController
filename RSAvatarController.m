//
//  RSAvatarController.m
//  RSAvatarController
//
//  Created by Rex Sheng on 7/6/12.
//

#import "RSAvatarController.h"
#import "RSMoveAndScaleController.h"
#import <QuartzCore/QuartzCore.h>

@interface RSAvatarController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, RSMoveAndScaleControllerDelegate, UIPopoverControllerDelegate>
@end

@implementation RSAvatarController
{
	UIPopoverController *popover;
	__weak UIViewController *parentController;
	UIAlertController *_actionSheet;
}

- (BOOL)takingAvatar
{
	return _imagePicker != nil;
}

- (void)openActionSheetInController:(UIViewController *)viewController
{
	parentController = viewController;
	_actionSheet = [UIAlertController alertControllerWithTitle:@"Pick photo" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self startPickingImage:true];
		}];
		[_actionSheet addAction:cameraAction];
	}

	UIAlertAction *existingAction = [UIAlertAction actionWithTitle:@"Choose existing photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self startPickingImage:false];
	}];
	[_actionSheet addAction:existingAction];
	
	_actionSheet.modalPresentationStyle = UIModalPresentationPopover;
	_actionSheet.popoverPresentationController.sourceView = viewController.view;
	CGRect v = [self.delegate popoverRectForAvatarController:self];
	_actionSheet.popoverPresentationController.sourceRect = v;
	[viewController presentViewController:_actionSheet animated:true completion:nil];
}

- (void)startPickingImage:(BOOL)fromCamera
{
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	if (fromCamera) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		UIView *overlay = nil;
		if ([self.delegate respondsToSelector:@selector(overlayForAvatarControllerImagePicker:)]) {
			overlay = [self.delegate overlayForAvatarControllerImagePicker:self];
		}
		if (overlay) {
			_imagePicker.showsCameraControls = NO;
			_imagePicker.cameraOverlayView = overlay;
		}
	}
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		popover = [[UIPopoverController alloc] initWithContentViewController:_imagePicker];
		popover.delegate = self;
		[popover presentPopoverFromRect:[self.delegate popoverRectForAvatarController:self] inView:parentController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[parentController presentViewController:_imagePicker animated:YES completion:nil];
	}
}

- (UIImagePickerControllerCameraFlashMode)cameraFlashMode
{
	return _imagePicker.cameraFlashMode;
}

- (void)switchCamera
{
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	} else {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	}
}

- (void)switchFlashMode
{
	if (_imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
	} else {
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	RSMoveAndScaleController *moveAndScale = [[RSMoveAndScaleController alloc] init];
	moveAndScale.originImage = originImage;
	moveAndScale.destinationSize = [self.delegate destinationImageSizeForAvatarController:self];
	if ([self.delegate respondsToSelector:@selector(destinationImageUploadSizeForAvatarController:)]) {
		moveAndScale.uploadSize = [self.delegate destinationImageUploadSizeForAvatarController:self];
	} else {
		moveAndScale.uploadSize = moveAndScale.destinationSize;
	}
	moveAndScale.overlayView = [self.delegate avatarController:self overlayForMoveAndScale:moveAndScale];
	if ([self.delegate respondsToSelector:@selector(contentModeForAvatarController:)]) {
		moveAndScale.minimumContentMode = [self.delegate contentModeForAvatarController:self];
	}
	moveAndScale.delegate = self;
	[picker pushViewController:moveAndScale animated:NO];
}

- (void)moveAndScaleController:(RSMoveAndScaleController *)moveAndScale didFinishCropping:(UIImage *)destImage
{
	[self.delegate avatarController:self pickedAvatar:destImage];
	[self.imagePicker popToRootViewControllerAnimated:NO];
	[self imagePickerControllerDidCancel:self.imagePicker];
}

- (void)moveAndScaleControllerDidCancel:(RSMoveAndScaleController *)moveAndScale
{
	if ([self.delegate respondsToSelector:@selector(avatarControllerDidCancel:)]) {
		[self.delegate avatarControllerDidCancel:self];
	}
	[self.imagePicker popToRootViewControllerAnimated:NO];
	[self imagePickerControllerDidCancel:self.imagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	if ([self.delegate respondsToSelector:@selector(avatarControllerDidCancel:)]) {
		[self.delegate avatarControllerDidCancel:self];
	}
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		popover = nil;
	} else {
		[picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
			_imagePicker = nil;
		}];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	popover = nil;
	_imagePicker = nil;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)])
		[self.delegate navigationController:navigationController didShowViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
		[self.delegate navigationController:navigationController willShowViewController:viewController animated:animated];
}

@end