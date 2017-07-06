//
//  LoadingStatus.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 View for displaying the loading status.
 */

import UIKit
import Foundation

@objc(LoadingStatus)
class LoadingStatus : UIView {
    
    private let progress: UIActivityIndicatorView
    private let loadingLabel: UILabel
    
    
    //MARK: -
    
    class func defaultLoadingStatusWithWidth(_ width: CGFloat) -> LoadingStatus {
        
        return LoadingStatus(frame: CGRect(x: 0.0, y: 0.0, width: width, height: 40.0))
    }
    
    override init(frame: CGRect) {
        
        let loadingString = "Loading Photos…"
        
        let loadingFont = UIFont.boldSystemFont(ofSize: 17.0)
        
        let attrs: [String : AnyObject] = [NSFontAttributeName : loadingFont]

        let rect = loadingString.boundingRect(with: CGSize(width: frame.width, height: frame.height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs,
            context: nil)
        let labelSize = rect.size
        
        let centerX = floor((frame.width / 2.0) - (labelSize.width / 2.0))
        let centerY = floor((frame.height / 2.0) - (labelSize.height / 2.0))
        loadingLabel = UILabel(frame: CGRect(x: centerX, y: centerY, width: labelSize.width, height: labelSize.height))
        self.loadingLabel.backgroundColor = UIColor.clear
        self.loadingLabel.textColor = UIColor.white
        self.loadingLabel.text = loadingString
        self.loadingLabel.font = loadingFont
        
        progress = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        var progressFrame = self.progress.frame
        progressFrame.origin.x = centerX - progressFrame.width - 8.0
        progressFrame.origin.y = centerY
        self.progress.frame = progressFrame
        
        self.addSubview(self.progress)
        self.addSubview(self.loadingLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        
        if subview === self.progress {
            self.progress.stopAnimating()
        }
        
        super.willRemoveSubview(subview)
    }
    
    override func didMoveToWindow() {
        
        super.didMoveToWindow()
        
        self.progress.startAnimating()
    }
    
    func removeFromSuperviewWithFade() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
            }, completion: {finished in
                if finished {
                    self.removeFromSuperview()
                }
        }) 
    }
    
}
