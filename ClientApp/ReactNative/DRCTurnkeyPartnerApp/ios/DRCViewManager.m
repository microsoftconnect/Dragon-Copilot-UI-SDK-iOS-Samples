//
//  DRCViewManager.m
//  iOSEmbeddedPartnerApp
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

#import "DRCViewManager.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>

@implementation DRCViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
  UIViewController *viewController = [[UIViewController alloc] init];
  UIView *view = viewController.view;
  view.backgroundColor = [UIColor whiteColor];
  return view;
}

@end
