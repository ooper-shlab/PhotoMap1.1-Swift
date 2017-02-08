//
//  PhotoMapAppDelegate.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/12/11.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A basic UIApplication delegate which sets up the application.
 */

import UIKit

@UIApplicationMain
@objc(PhotoMapAppDelegate)
class PhotoMapAppDelegate : NSObject, UIApplicationDelegate {

    // The app delegate must implement the window @property
    // from UIApplicationDelegate @protocol to use a main storyboard file.
    //
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        return true
    }

}
