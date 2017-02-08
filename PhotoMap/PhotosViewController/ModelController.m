/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The model or data source for PhotosViewController.
 */

#import "ModelController.h"
#import "DataViewController.h"
#import "PhotosViewController.h"

/*
 A controller object that manages a simple model -- a collection of map annotations
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@implementation ModelController

- (id)init {
    self = [super init];
    if (self != nil) {
        _currentPageIndex = 0;
    }
    return self;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // return the data view controller for the given index
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // vreate a new view controller and pass suitable data
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.dataObject = self.pageData[index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the
    // view controller stores the model object; you can therefore use the model object to identify the index.
    //
    return [self.pageData indexOfObject:viewController.dataObject];
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    PhotosViewController *photosViewController = (PhotosViewController *)pageViewController.delegate;
    
    if (photosViewController.pageAnimationFinished == NO) {
        // we are still animating don't return a previous view controller too soon
        return nil;
    }
    
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == 0 || index == NSNotFound) {
        // we are at the first page, don't go back any further
        return nil;
    }
    
    index--;
    _currentPageIndex = index;
    
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    PhotosViewController *photosViewController = (PhotosViewController *)pageViewController.delegate;
    
    if (photosViewController.pageAnimationFinished == NO) {
        // we are still animating don't return a next view controller too soon
        return nil;
    }
    
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        // we are at the last page, don't go back any further
        return nil;
    }
    
    index++;
    _currentPageIndex = index;
    
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
