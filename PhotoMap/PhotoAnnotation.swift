//
//  PhotoAnnotation.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
     File: PhotoAnnotation.h
     File: PhotoAnnotation.m
 Abstract: A simple model class to display pins representing photos on the map.
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
