//
//  DataViewController.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 The view controller representing each page in PhotosViewController.
 */

import UIKit

@objc(DataViewController)
class DataViewController: UIViewController {
    
    var dataObject: PhotoAnnotation?
    
    @IBOutlet private weak var imageView: UIImageView?
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // we want for the title to only be the image name (obtained from the file system path)
        var title = (self.dataObject?.imagePath as NSString?)?.lastPathComponent
        title = (title as NSString?)?.deletingPathExtension
        self.title = title
        
        self.imageView?.image = self.dataObject?.image
    }
    
}
