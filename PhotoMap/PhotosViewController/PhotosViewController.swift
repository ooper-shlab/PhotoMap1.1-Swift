//
//  PhotosViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The secondary view controller used for browing the photos.
 */

import UIKit

@objc(PhotosViewController)
class PhotosViewController: UIViewController, UIPageViewControllerDelegate {
    
    var photosToShow: [PhotoAnnotation] = []
    var pageAnimationFinished: Bool = false
    
    private lazy var modelController: ModelController = ModelController()
    private var pageViewController: UIPageViewController?
    
    
    //#MARK: -
    
    private func updateNavBarTitle() {
        
        if self.modelController.pageData.count > 1 {
            self.title = "Photos (\(self.modelController.currentPageIndex + 1) of \(self.modelController.pageData.count))"
        } else {
            let viewController = self.modelController.pageData[self.modelController.currentPageIndex] //Original sample code's bug?
            self.title = viewController.title
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        pageViewController =
            UIPageViewController(transitionStyle: .pageCurl,
                navigationOrientation: .horizontal,
                options: nil)
        self.pageViewController!.delegate = self
        
        self.modelController.pageData = self.photosToShow
        
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let startingViewController = self.modelController.viewControllerAtIndex(0, storyboard: storyboard)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers,
            direction: .forward,
            animated: false,
            completion: nil)
        
        self.updateNavBarTitle()
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        self.pageViewController!.didMove(toParentViewController: self)
        
        // add the page view controller's gesture recognizers to the book view controller's view
        // so that the gestures are started more easily
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        pageAnimationFinished = true
    }
    
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    
    
    //#MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // update the nav bar title showing which index we are displaying
        self.updateNavBarTitle()
        
        pageAnimationFinished = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        
        // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        let currentViewController = self.pageViewController!.viewControllers![0]
        let viewControllers = [currentViewController]
        self.pageViewController!.setViewControllers(viewControllers,
            direction: .forward,
            animated: true,
            completion: nil)
        
        self.pageViewController!.isDoubleSided = false
        return .min
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pageAnimationFinished = false
    }
    
}
