/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View for displaying the loading status.
 */

@import UIKit;

@interface LoadingStatus : UIView

+ (id)defaultLoadingStatusWithWidth:(CGFloat)width;
- (void)removeFromSuperviewWithFade;

@end
