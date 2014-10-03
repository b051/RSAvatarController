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

  // center the button
  button.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint * centerX = [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual toItem:self.view
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0 constant:0];
  NSLayoutConstraint * centerY = [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual toItem:self.view
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0 constant:0];
  [self.view addConstraints:@[centerX,centerY]];
}


- (void) handleTap:(id)sender {
  self.rsAvatarController = [[RSAvatarController alloc] init];
  [self.rsAvatarController openActionSheetInController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
