//
//  PhotoMapViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Primary map view controller.
 */

import UIKit
import MapKit
import ImageIO

func synchronized(_ object: AnyObject, block: () -> Void) {
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
    
    private func photoSetFromPath(_ path: String) -> NSArray {
        
        let photos = NSMutableArray()
        
        // The bulk of our work here is going to be loading the files and looking up metadata
        // Thus, we see a major speed improvement by loading multiple photos simultaneously
        //
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 8
        
        let photoURLs = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: path)
        for photoURL in photoURLs ?? [] {
            queue.addOperation {
                let imageData = try! Data(contentsOf: photoURL)
                let dataProvider = CGDataProvider(data: imageData as CFData)
                let imageSource = CGImageSourceCreateWithDataProvider(dataProvider!, nil)
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String: AnyObject]
                
                // check if the image is geotagged
                if let gpsInfo = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: AnyObject] {
                    let latitude = gpsInfo[kCGImagePropertyGPSLatitude as String] as! Double
                    let longitude = gpsInfo[kCGImagePropertyGPSLongitude as String] as! Double
                    var coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    if gpsInfo[kCGImagePropertyGPSLatitudeRef as String] as? String == "S" {
                        coord.latitude = -coord.latitude
                    }
                    if gpsInfo[kCGImagePropertyGPSLongitudeRef as String] as? String == "W" {
                        coord.longitude = -coord.longitude
                    }

                    let fileName = photoURL.deletingPathExtension().lastPathComponent
                    let photo = PhotoAnnotation(imagePath: photoURL.path, title: fileName, coordinate: coord)
                    
                    synchronized(photos) {
                        photos.add(photo)
                    }
                }
                
            }
        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        return photos
    }
    
    private func populateMapWithAllPhotoAnnotations() {
        
        // add a temporary loading view
        let loadingStatus = LoadingStatus.defaultLoadingStatusWithWidth(self.view.frame.width)
        self.view.addSubview(loadingStatus)
        
        // loading/processing photos might take a while -- do it asynchronously
        DispatchQueue.global(qos: .default).async {
            let photos = self.photoSetFromPath("PhotoSet")
            
            self.photos = photos
            
            DispatchQueue.main.async {
                self.allAnnotationsMapView!.addAnnotations(self.photos as! [MKAnnotation])
                self.updateVisibleAnnotations()
                
                loadingStatus.removeFromSuperviewWithFade()
            }
        }
    }
    
    private func annotationInGrid(_ gridMapRect: MKMapRect, usingAnnotations annotations: Set<PhotoAnnotation>) -> MKAnnotation {
        
        // first, see if one of the annotations we were already showing is in this mapRect
        let visibleAnnotatonsInBucket = self.mapView!.annotations(in: gridMapRect)
        if let annotationForGridSet = annotations.first(where: { annotation in
            visibleAnnotatonsInBucket.contains(annotation)
        })  {
            return annotationForGridSet
        }
        
        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect))
        let sortedAnnotations = annotations.sorted {obj1, obj2 in
            let mapPoint1 = MKMapPointForCoordinate(obj1.coordinate)
            let mapPoint2 = MKMapPointForCoordinate(obj2.coordinate)
            
            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)
            
            return distance1 < distance2
        }
        
        return sortedAnnotations[0]
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
        let leftCoordinate = self.mapView!.convert(CGPoint.zero, toCoordinateFrom: self.view)
        let rightCoordinate = self.mapView!.convert(CGPoint(x: bucketSize, y: 0), toCoordinateFrom: self.view)
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
                let allAnnotationsInBucket = self.allAnnotationsMapView?.annotations(in: gridMapRect)
                let visibleAnnotationsInBucket = self.mapView!.annotations(in: gridMapRect)
                
                // we only care about PhotoAnnotations
                var filteredAnnotationsInBucket = allAnnotationsInBucket == nil ?
                    Set<PhotoAnnotation>()
                : Set<PhotoAnnotation>(allAnnotationsInBucket!.lazy.flatMap {obj in
                    obj as? PhotoAnnotation
                    })
                
                if filteredAnnotationsInBucket.count > 0 {
                    let annotationForGrid = self.annotationInGrid(gridMapRect, usingAnnotations: filteredAnnotationsInBucket) as! PhotoAnnotation
                    
                    filteredAnnotationsInBucket.remove(annotationForGrid)
                    
                    // give the annotationForGrid a reference to all the annotations it will represent
                    annotationForGrid.containedAnnotations = Array(filteredAnnotationsInBucket)
                    
                    self.mapView!.addAnnotation(annotationForGrid)
                    
                    for annotation in filteredAnnotationsInBucket {
                        // give all the other annotations a reference to the one which is representing them
                        annotation.clusterAnnotation = annotationForGrid
                        annotation.containedAnnotations = []
                        
                        // remove annotations which we've decided to cluster
                        if visibleAnnotationsInBucket.contains(annotation) {
                            let actualCoordinate = annotation.coordinate
                            UIView.animate(withDuration: 0.3, animations: {
                                annotation.setCoordinate(annotation.clusterAnnotation!.coordinate)
                            }, completion: {finished in
                                    annotation.setCoordinate(actualCoordinate)
                                    self.mapView!.removeAnnotation(annotation)
                            }) 
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
        
        allAnnotationsMapView = MKMapView(frame: CGRect.zero)
        
        // now load all photos from Resources and add them as annotations to the map view
        self.populateMapWithAllPhotoAnnotations()
    }
    
    @IBAction private func zoomToCherryLake(_: AnyObject) {
        
        // clear any annotations in preparation for zooming
        self.mapView!.removeAnnotations(self.mapView!.annotations)
        
        // center to Cherry Lake to see the rest of the annotations
        let newRegion = MKCoordinateRegionMake(CherryLakeLocation, MKCoordinateSpanMake(0.05, 0.05))
        
        self.mapView!.setRegion(newRegion, animated: true)
        
    }
    
    //#MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        self.updateVisibleAnnotations()
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        for annotationView in views as [MKAnnotationView] {
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
                
                UIView.animate(withDuration: 0.3, animations: {
                    annotation.setCoordinate(actualCoordinate)
                }) 
            }
        }
    }
    
    func mapView(_ aMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "Photo"
        
        if aMapView != self.mapView {
            return nil
        }
        
        if annotation is PhotoAnnotation {
            var annotationView = self.mapView!.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as! MKPinAnnotationView?
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            annotationView!.canShowCallout = true
            
            let disclosureButton = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = disclosureButton
            
            return annotationView
        }
        
        return nil
    }
    
    // user tapped the call out accessory 'i' button
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotation = view.annotation as! PhotoAnnotation
        
        var photosToShow = [annotation]
        photosToShow.append(contentsOf: annotation.containedAnnotations)
        
        let viewController = PhotosViewController()
        viewController.edgesForExtendedLayout = UIRectEdge()
        viewController.photosToShow = photosToShow
        
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation is PhotoAnnotation {
            let annotation = view.annotation as! PhotoAnnotation
            annotation.updateSubtitleIfNeeded()
        }
    }
    
}
