//
//  PhotoMapViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
     File: PhotoMapViewController.h
     File: PhotoMapViewController.m
 Abstract: Primary map view controller.
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
import MapKit
import ImageIO

func synchronized(object: AnyObject, block: () -> Void) {
    objc_sync_enter(object)
    block()
    objc_sync_exit(object)
}


@objc(PhotoMapViewController)
class PhotoMapViewController: UIViewController, MKMapViewDelegate {
    
    private var photos: NSArray?
    private var allAnnotationsMapView: MKMapView?
    
    @IBOutlet private var mapView: MKMapView?
    
    
    //#MARK: -
    
    private func photoSetFromPath(path: String) -> NSArray {
        
        let photos = NSMutableArray()
        
        // The bulk of our work here is going to be loading the files and looking up metadata
        // Thus, we see a major speed improvement by loading multiple photos simultaneously
        //
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 8
        
        let photoPaths = NSBundle.mainBundle().pathsForResourcesOfType("jpg", inDirectory: path)
        for photoPath in photoPaths as! [String] {
            queue.addOperationWithBlock {
                let imageData = NSData(contentsOfFile: photoPath)!
                let dataProvider = CGDataProviderCreateWithCFData(imageData as CFDataRef)
                let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil)
                let imageProperties: NSDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
                
                // check if the image is geotagged
                let gpsInfo = imageProperties[kCGImagePropertyGPSDictionary as NSString] as! NSDictionary?
                if gpsInfo != nil {
                    let latitude = gpsInfo![kCGImagePropertyGPSLatitude as NSString]!.doubleValue
                    let longitude = gpsInfo![kCGImagePropertyGPSLongitude as NSString]!.doubleValue
                    var coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    if gpsInfo![kCGImagePropertyGPSLatitudeRef as NSString] as! String? == "S" {
                        coord.latitude = -coord.latitude
                    }
                    if gpsInfo![kCGImagePropertyGPSLongitudeRef as NSString] as! String? == "W" {
                        coord.longitude = -coord.longitude
                    }
                    
                    let fileName = photoPath.lastPathComponent.stringByDeletingPathExtension
                    let photo = PhotoAnnotation(imagePath: photoPath, title: fileName, coordinate: coord)
                    
                    synchronized(photos) {
                        photos.addObject(photo)
                    }
                }
                
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        return photos
    }
    
    private func populateWorldWithAllPhotoAnnotations() {
        
        // add a temporary loading view
        let loadingStatus = LoadingStatus.defaultLoadingStatusWithWidth(CGRectGetWidth(self.view.frame))
        self.view.addSubview(loadingStatus)
        
        // loading/processing photos might take a while -- do it asynchronously
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let photos = self.photoSetFromPath("PhotoSet")
            
            self.photos = photos
            
            dispatch_async(dispatch_get_main_queue()) {
                self.allAnnotationsMapView!.addAnnotations(self.photos as! [AnyObject])
                self.updateVisibleAnnotations()
                
                loadingStatus.removeFromSuperviewWithFade()
            }
        }
    }
    
    private func annotationInGrid(gridMapRect: MKMapRect, usingAnnotations annotations: NSSet) -> MKAnnotation {
        
        // first, see if one of the annotations we were already showing is in this mapRect
        let visibleAnnotatonsInBucket = self.mapView!.annotationsInMapRect(gridMapRect)
        let annotationsForGridSet = annotations.objectsPassingTest {obj, stop in
            let returnValue = visibleAnnotatonsInBucket.contains(obj as! NSObject)
            if returnValue {
                stop.memory = true
            }
            return returnValue
        }
        
        if annotationsForGridSet.count != 0 {
            return annotationsForGridSet.first as! MKAnnotation
        }
        
        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect))
        let sortedAnnotations = annotations.allObjects.sorted {obj1, obj2 in
            let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
            let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)
            
            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)
            
            return distance1 < distance2
        }
        
        return sortedAnnotations[0] as! MKAnnotation
    }
    
    private func updateVisibleAnnotations() {
        
        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor: Double = 2.0
        
        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize: CGFloat = 60.0
        
        // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
        let visibleMapRect = self.mapView!.visibleMapRect
        let adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height)
        
        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = self.mapView!.convertPoint(CGPointZero, toCoordinateFromView: self.view)
        let rightCoordinate = self.mapView!.convertPoint(CGPointMake(bucketSize, 0), toCoordinateFromView: self.view)
        let gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x
        var gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize)
        
        // condense annotations, with a padding of two squares, around the visibleMapRect
        let startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize
        let startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize
        let endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize
        let endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize
        
        // for each square in our grid, pick one annotation to show
        gridMapRect.origin.y = startY
        while MKMapRectGetMinY(gridMapRect) <= endY {
            gridMapRect.origin.x = startX
            
            while MKMapRectGetMinX(gridMapRect) <= endX {
                let allAnnotationsInBucket = self.allAnnotationsMapView?.annotationsInMapRect(gridMapRect)
                let visibleAnnotationsInBucket = self.mapView!.annotationsInMapRect(gridMapRect)
                
                // we only care about PhotoAnnotations
                var filteredAnnotationsInBucket = allAnnotationsInBucket == nil ?
                    Set<NSObject>()
                : Set(lazy(allAnnotationsInBucket!).filter {obj in
                    obj is PhotoAnnotation
                    })
                
                if filteredAnnotationsInBucket.count > 0 {
                    let annotationForGrid = self.annotationInGrid(gridMapRect, usingAnnotations: filteredAnnotationsInBucket) as! PhotoAnnotation
                    
                    filteredAnnotationsInBucket.remove(annotationForGrid)
                    
                    // give the annotationForGrid a reference to all the annotations it will represent
                    annotationForGrid.containedAnnotations = Array(filteredAnnotationsInBucket)
                    
                    self.mapView!.addAnnotation(annotationForGrid)
                    
                    for _annotation in filteredAnnotationsInBucket {
                        let annotation = _annotation as! PhotoAnnotation
                        // give all the other annotations a reference to the one which is representing them
                        annotation.clusterAnnotation = annotationForGrid
                        annotation.containedAnnotations = nil
                        
                        // remove annotations which we've decided to cluster
                        if visibleAnnotationsInBucket.contains(annotation) {
                            let actualCoordinate = annotation.coordinate
                            UIView.animateWithDuration(0.3, animations: {
                                annotation.setCoordinate(annotation.clusterAnnotation!.coordinate)
                            }) {finished in
                                    annotation.setCoordinate(actualCoordinate)
                                    self.mapView!.removeAnnotation(annotation)
                            }
                        }
                    }
                }
                
                gridMapRect.origin.x += gridSize
            }
            
            gridMapRect.origin.y += gridSize
        }
    }
    
    
    //#MARK: - UIViewController
    
    private let CherryLakeLocation = CLLocationCoordinate2D(latitude: 38.002493, longitude: -119.9078987)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // center to Cherry Lake, but zoomed outward
        let newRegion = MKCoordinateRegionMake(CherryLakeLocation, MKCoordinateSpanMake(5.0, 5.0))
        self.mapView!.region = newRegion
        
        allAnnotationsMapView = MKMapView(frame: CGRectZero)
        
        // now load all photos from Resources and add them as annotations to the mapview
        self.populateWorldWithAllPhotoAnnotations()
    }
    
    @IBAction private func zoomToCherryLake(AnyObject) {
        
        // clear any annotations in preparation for zooming
        self.mapView!.removeAnnotations(self.mapView!.annotations)
        
        // center to Cherry Lake to see the rest of the annotations
        let newRegion = MKCoordinateRegionMake(CherryLakeLocation, MKCoordinateSpanMake(0.05, 0.05))
        
        self.mapView!.setRegion(newRegion, animated: true)
        
    }
    
    //#MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        
        self.updateVisibleAnnotations()
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        
        for annotationView in views as! [MKAnnotationView] {
            if !(annotationView.annotation is PhotoAnnotation) {
                continue
            }
            
            let annotation = annotationView.annotation as! PhotoAnnotation
            
            if annotation.clusterAnnotation != nil {
                // animate the annotation from it's old container's coordinate, to its actual coordinate
                let actualCoordinate = annotation.coordinate
                let containerCoordinate = annotation.clusterAnnotation!.coordinate
                
                // since it's displayed on the map, it is no longer contained by another annotation,
                // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
                // to get the containerCoordinate)
                annotation.clusterAnnotation = nil
                
                annotation.setCoordinate(containerCoordinate)
                
                UIView.animateWithDuration(0.3) {
                    annotation.setCoordinate(actualCoordinate)
                }
            }
        }
    }
    
    func mapView(aMapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let annotationIdentifier = "Photo"
        
        if aMapView != self.mapView {
            return nil
        }
        
        if annotation is PhotoAnnotation {
            var annotationView = self.mapView!.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as! MKPinAnnotationView?
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            annotationView!.canShowCallout = true
            
            let disclosureButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            annotationView!.rightCalloutAccessoryView = disclosureButton
            
            return annotationView
        }
        
        return nil
    }
    
    // user tapped the call out accessory 'i' button
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let annotation = view.annotation as! PhotoAnnotation
        
        let photosToShow = NSMutableArray(object: annotation)
        photosToShow.addObjectsFromArray(annotation.containedAnnotations! as! [AnyObject])
        
        let viewController = PhotosViewController()
        viewController.edgesForExtendedLayout = .None
        viewController.photosToShow = photosToShow
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        if view.annotation is PhotoAnnotation {
            let annotation = view.annotation as! PhotoAnnotation
            annotation.updateSubtitleIfNeeded()
        }
    }
    
}