/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A simple model class to display pins representing photos on the map.
 */

#import "PhotoAnnotation.h"
@import CoreLocation;

@implementation PhotoAnnotation

- (id)initWithImagePath:(NSString *)anImagePath title:(NSString *)aTitle coordinate:(CLLocationCoordinate2D)aCoordinate {
    
    self = [super init];
    if (self != nil) {
        self.imagePath = anImagePath;
        self.title = aTitle;
        self.coordinate = aCoordinate;
    }
    return self;
}

- (NSString *)title {
    
    if (self.containedAnnotations.count > 0) {
        return [NSString stringWithFormat:@"%zd Photos", self.containedAnnotations.count + 1];
    }
    
    return _title;
}

- (UIImage *)image {
    
    if (!_image && self.imagePath) {
        _image = [UIImage imageWithContentsOfFile:self.imagePath];
    }
    return _image;
}

- (NSString *)stringForPlacemark:(CLPlacemark *)placemark {
    
    NSMutableString *string = [[NSMutableString alloc] init];
    if (placemark.locality) {
        [string appendString:placemark.locality];
    }
    
    if (placemark.administrativeArea) {
        if (string.length > 0)
            [string appendString:@", "];
        [string appendString:placemark.administrativeArea];
    }
    
    if (string.length == 0 && placemark.name)
        [string appendString:placemark.name];
    
    return string;
}

- (void)updateSubtitleIfNeeded {
    
    if (self.subtitle == nil) {
        // for the subtitle, we reverse geocode the lat/long for a proper location string name
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = placemarks[0];
                self.subtitle = [NSString stringWithFormat:@"Near %@", [self stringForPlacemark:placemark]];
            }
        }];
    }
}

@end
