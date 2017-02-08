//
//  PhotoAnnotation.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A simple model class to display pins representing photos on the map.
 */

import Foundation
import MapKit
import CoreLocation

@objc(PhotoAnnotation)
class PhotoAnnotation: NSObject, MKAnnotation {

    private var _image: UIImage?
    var image: UIImage? {
        get { return getImage() }
    }
    var imagePath: String?
    private var _title: String
    var title: String? {
        get { return getTitle() }
    }
    var subtitle: String?
    var _coordinate: CLLocationCoordinate2D
    dynamic var coordinate: CLLocationCoordinate2D {  //must be KVO compliant. (see MKAnnotation)
        get { return _coordinate }
    }
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        self._coordinate = newCoordinate
    }

    var clusterAnnotation: PhotoAnnotation?
    var containedAnnotations: [PhotoAnnotation] = []

    init(imagePath anImagePath: String, title aTitle: String, coordinate aCoordinate: CLLocationCoordinate2D) {

        self.imagePath = anImagePath
        self._title = aTitle
        self._coordinate = aCoordinate
        super.init()
    }

    private func getTitle() -> String {

        if self.containedAnnotations.count > 0 {
            return String(format: "%zd Photos", self.containedAnnotations.count + 1)
        }

        return _title
    }

    private func getImage() -> UIImage? {

        if _image == nil && self.imagePath != nil {
            _image = UIImage(contentsOfFile: self.imagePath!)
        }
        return _image
    }

    private func stringForPlacemark(_ placemark: CLPlacemark) -> String {

        var string = ""
        if placemark.locality != nil {
            string += placemark.locality!
        }

        if placemark.administrativeArea != nil {
            if !string.isEmpty {
                string += ", "
            }
            string += placemark.administrativeArea!
        }

        if string.isEmpty && placemark.name != nil {
            string += placemark.name!
        }

        return string
    }

    func updateSubtitleIfNeeded() {

        if self.subtitle == nil {
        // for the subtitle, we reverse geocode the lat/long for a proper location string name
            let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {placemarks, error in
                if placemarks?.count ?? 0 > 0 {
                    let placemark = placemarks![0]
                    self.subtitle = "Near \(self.stringForPlacemark(placemark))"
                }
            }
        }
    }

}
