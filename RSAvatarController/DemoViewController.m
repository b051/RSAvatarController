//
//  DemoViewController.m
//  RSAvatarController
//
//  Created by Alexis Gallagher on 2014-10-03.
//  Copyright (c) 2014 Rex Sheng. All rights reserved.
//

#import "DemoViewController.h"
#import "RSAvatarController.h"

@interface DemoViewController ()
@property (strong,nonatomic) RSAvatarController * rsAvatarController;
@property (weak,nonatomic) UIImageView * pickedImageView;
@end

@interface DemoViewController  (RSAvatarControllerDelegate) <RSAvatarControllerDelegate>
- (void)avatarController:(RSAvatarController *)controller pickedAvatar:(UIImage *)avatar;
- (UIView *)avatarController:(RSAvatarController *)controller overlayForMoveAndScale:(id<RSMoveAndScaleTrait>)trait;
- (CGRect)popoverRectForAvatarController:(RSAvatarController *)controller;
- (CGSize)destinationImageSizeForAvatarController:(RSAvatarController *)controller;

//@optional
- (UIView *)overlayForAvatarControllerImagePicker:(RSAvatarController *)controller;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  // add a button that launches the RSAvatarController
  UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:@"LAUNCH RSAVATARCONTROLLER" forState:UIControlStateNormal];
  [button addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  
  // add a UIImageView beneath it.
  UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  [self.view addSubview:imageView];
  self.pickedImageView = imageView;

  // center the button
  button.translatesAutoresizingMaskIntoConstraints = NO;
  imageView.translatesAutoresizingMaskIntoConstraints = NO;
  UIView * superview = self.view;
  NSDictionary * views = NSDictionaryOfVariableBindings(button,imageView,superview);
  [@[@"V:|-(100)-[button]-(20)-[imageView]", // stack the views
     @"V:[superview]-(>=0)-[button]"]        // center them w/r/t/ superview
   enumerateObjectsUsingBlock:
   ^(NSString * visualFormat, NSUInteger idx, BOOL *stop) {
     [self.view addConstraints:
      [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                              options:NSLayoutFormatAlignAllCenterX
                                              metrics:nil views:views]];
   }];
}

- (void) handleTap:(id)sender {
  self.rsAvatarController = [[RSAvatarController alloc] init];
  self.rsAvatarController.delegate = self;
  [self.rsAvatarController openActionSheetInController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RSAvatarControllerDelegate

- (void)avatarController:(RSAvatarController *)controller pickedAvatar:(UIImage *)avatar
{
  NSLog(@"picked image=%@",avatar);
  self.pickedImageView.image = avatar;
}

- (UIView *)avatarController:(RSAvatarController *)controller
      overlayForMoveAndScale:(id<RSMoveAndScaleTrait>)trait
{
  /* 
   setup a view holding a "cancel" and "choose" button
   */
  UIView * moveAndScaleOverlay = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 200, 100)];
  
  UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
  
  UIButton * chooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [chooseButton setTitle:@"choose" forState:UIControlStateNormal];

  // wire up the buttons to call the trait object
  [cancelButton addTarget:trait action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
  [chooseButton addTarget:trait action:@selector(choose) forControlEvents:UIControlEventTouchUpInside];
  

  // set up layout so the buttons are left to right with a bit of padding
  [moveAndScaleOverlay addSubview:cancelButton];
  [moveAndScaleOverlay addSubview:chooseButton];
  
  NSDictionary * views = NSDictionaryOfVariableBindings(cancelButton,chooseButton);
  NSMutableArray * constraints = [NSMutableArray array];
  [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cancelButton]-(>=20)-[chooseButton]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
  [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[cancelButton]-(>=0)-|" options:0 metrics:nil views:views]];
  [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[chooseButton]-(>=0)-|" options:0 metrics:nil views:views]];
  cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
  chooseButton.translatesAutoresizingMaskIntoConstraints = NO;
  [moveAndScaleOverlay addConstraints:constraints];
  
  CGSize smallerSize = [moveAndScaleOverlay systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  moveAndScaleOverlay.frame = CGRectMake(moveAndScaleOverlay.frame.origin.x,moveAndScaleOverlay.frame.origin.y,
                                         smallerSize.width,smallerSize.height);
  
  return moveAndScaleOverlay;
}

- (CGRect)popoverRectForAvatarController:(RSAvatarController *)controller
{
  // TODO: implement example for iPad
  return CGRectMake(0, 0, 100, 100);
}

- (CGSize)destinationImageSizeForAvatarController:(RSAvatarController *)controller
{
  return CGSizeMake(150, 150);
}

//@optional
//- (UIView *)overlayForAvatarControllerImagePicker:(RSAvatarController *)controller
//{
//  return nil;
//}

#pragma mark debugging

-(void)logTap:(id)sender {
  NSLog(@"tap on %@",sender);
}
@end
