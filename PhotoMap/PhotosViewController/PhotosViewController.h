/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The secondary view controller used for browing the photos.
 */

@import UIKit;

@interface PhotosViewController : UIViewController <UIPageViewControllerDelegate>

@property (nonatomic, strong) NSArray *photosToShow;
@property BOOL pageAnimationFinished;

@end
