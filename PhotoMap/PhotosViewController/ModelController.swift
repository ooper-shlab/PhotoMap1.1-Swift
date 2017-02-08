//
//  ModelController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The model or data source for PhotosViewController.
 */

import UIKit

@objc(ModelController)
class ModelController: NSObject, UIPageViewControllerDataSource {
    
    var pageData: [PhotoAnnotation] = []
    var currentPageIndex: Int
    
    /*
    A controller object that manages a simple model -- a collection of map annotations
    
    The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
    It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
    
    There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
    */
    
    override init() {
        currentPageIndex = 0
        super.init()
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // return the data view controller for the given index
        if index >= self.pageData.count {
            return nil
        }
        
        // vreate a new view controller and pass suitable data
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController")
            as! DataViewController
        dataViewController.dataObject = self.pageData[index]
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the
        // view controller stores the model object; you can therefore use the model object to identify the index.
        //
        if viewController.dataObject == nil {
            return NSNotFound
        }   //This may never happen?
        return self.pageData.index(of: viewController.dataObject!)!
    }
    
    
    //#MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let photosViewController = pageViewController.delegate as! PhotosViewController?
        
        if !(photosViewController?.pageAnimationFinished ?? false) {
            // we are still animating don't return a previous view controller too soon
            return nil
        }
        
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == 0 || index == NSNotFound {
            // we are at the first page, don't go back any further
            return nil
        }
        
        index -= 1
        currentPageIndex = index
        
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let photosViewController = pageViewController.delegate as! PhotosViewController?
        
        if !(photosViewController?.pageAnimationFinished ?? false) {
            // we are still animating don't return a next view controller too soon
            return nil
        }
        
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            // we are at the last page, don't go back any further
            return nil
        }
        
        index += 1
        currentPageIndex = index
        
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}
