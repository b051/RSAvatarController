//
//  RSAvatarController.m
//  RSAvatarController
//
//  Created by Rex Sheng on 7/6/12.
//

#import "RSAvatarController.h"
#import "RSMoveAndScaleController.h"

@interface RSAvatarController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, RSMoveAndScaleControllerDelegate, UIPopoverControllerDelegate>
@end

@implementation RSAvatarController
{
	UIPopoverController *popover;
	__weak UIViewController *parentController;
}

- (BOOL)takingAvatar
{
	return _imagePicker != nil;
}

- (void)openActionSheetInController:(UIViewController *)viewController
{
	[self openActionSheetInController:viewController withSheetStyle:UIActionSheetStyleDefault];
}

- (void)openActionSheetInController:(UIViewController *)viewController withSheetStyle:(UIActionSheetStyle)sheetStyle
{
	parentController = viewController;
	UIActionSheet *actionSheet = nil;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Select from Gallery", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select from Gallery", nil];
	}
	actionSheet.actionSheetStyle = sheetStyle;
	[actionSheet showInView:viewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet.cancelButtonIndex == buttonIndex) {
		_imagePicker = nil;
		return;
	}
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		if (actionSheet.firstOtherButtonIndex == buttonIndex) {
			_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			UIView *overlay = nil;
			if ([self.delegate respondsToSelector:@selector(overlayForImagePicker:)]) {
				overlay = [self.delegate overlayForImagePicker:_imagePicker];
			}
			if (overlay) {
				_imagePicker.showsCameraControls = NO;
				_imagePicker.cameraOverlayView = overlay;
			}
		}
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		popover = [[UIPopoverController alloc] initWithContentViewController:_imagePicker];
		popover.delegate = self;
		[popover presentPopoverFromRect:[self.delegate rectForAvatarPopover] inView:parentController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
	moveAndScale.destinationSize = [self.delegate destImageSize];
	moveAndScale.overlayView = [self.delegate overlayForMoveAndScale:moveAndScale];
	moveAndScale.delegate = self;
	[picker pushViewController:moveAndScale animated:NO];
}

- (void)moveAndScaleController:(RSMoveAndScaleController *)moveAndScale didFinishCropping:(UIImage *)destImage
{
	[self.delegate pickerController:_imagePicker pickedAvatar:destImage];
	[self imagePickerControllerDidCancel:nil];
}

- (void)moveAndScaleControllerDidCancel:(RSMoveAndScaleController *)moveAndScale
{
	[self imagePickerControllerDidCancel:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		popover = nil;
	} else {
		[picker dismissViewControllerAnimated:YES completion:^{
			_imagePicker = nil;
		}];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	popover = nil;
	_imagePicker = nil;
}

@end