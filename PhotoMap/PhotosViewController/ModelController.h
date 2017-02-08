/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The model or data source for PhotosViewController.
 */

@import UIKit;

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray *pageData;
@property (assign) NSInteger currentPageIndex;

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end
