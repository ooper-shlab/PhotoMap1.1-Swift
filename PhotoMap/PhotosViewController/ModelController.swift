//
//  ModelController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
     File: ModelController.h
     File: ModelController.m
 Abstract: The model or data source for PhotosViewController.
  Version: 1.1

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2014 Apple Inc. All Rights Reserved.

 */

import UIKit

@objc(ModelController)
class ModelController: NSObject, UIPageViewControllerDataSource {
    
    var pageData: NSArray?
    var currentPageIndex: NSInteger
    
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
    
    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // return the data view controller for the given index
        if index >= (self.pageData?.count ?? 0) {
            return nil
        }
        
        // vreate a new view controller and pass suitable data
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController")
            as! DataViewController
        dataViewController.dataObject = (self.pageData![index] as! PhotoAnnotation)
        return dataViewController
    }
    
    func indexOfViewController(viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the
        // view controller stores the model object; you can therefore use the model object to identify the index.
        //
        if pageData == nil || viewController.dataObject == nil {
            return NSNotFound
        }   //This may never happen?
        return self.pageData!.indexOfObject(viewController.dataObject!)
    }
    
    
    //#MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
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
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
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
        
        if index == (self.pageData?.count ?? 0) {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}