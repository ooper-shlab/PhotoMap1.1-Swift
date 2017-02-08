/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The secondary view controller used for browing the photos.
 */

#import "PhotosViewController.h"
#import "ModelController.h"
#import "DataViewController.h"

@interface PhotosViewController ()

@property (strong, nonatomic) ModelController *modelController;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end


#pragma mark -

@implementation PhotosViewController

- (void)updateNavBarTitle {
    
    if (self.modelController.pageData.count > 1) {
        self.title = [NSString stringWithFormat:@"Photos (%zd of %zd)", self.modelController.currentPageIndex + 1, (long)self.modelController.pageData.count];
    }
    else {
        DataViewController *viewController = [self.modelController.pageData objectAtIndex:self.modelController.currentPageIndex];
        self.title = viewController.title;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    _pageViewController =
        [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                        navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                      options:nil];
    self.pageViewController.delegate = self;
    
    self.modelController.pageData = self.photosToShow;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    [self updateNavBarTitle];

    self.pageViewController.dataSource = self.modelController;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    _pageAnimationFinished = YES;
}

- (ModelController *)modelController {
    
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (_modelController == nil) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    // update the nav bar title showing which index we are displaying
    [self updateNavBarTitle];
    
    _pageAnimationFinished = YES;
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller.
    // Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    _pageAnimationFinished = NO;
}

@end
