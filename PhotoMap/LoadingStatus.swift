//
//  LoadingStatus.swift
//  PhotoMap
//
//  Translated by OOPer in cooperation with shlab.jp, on 2014/11/23.
//
//
/*
     File: LoadingStatus.h
     File: LoadingStatus.m
 Abstract: View for displaying the loading status.
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
import Foundation

@objc(LoadingStatus)
class LoadingStatus : UIView {
    
    private let progress: UIActivityIndicatorView
    private let loadingLabel: UILabel
    
    
    //MARK: -
    
    class func defaultLoadingStatusWithWidth(width: CGFloat) -> LoadingStatus {
        
        return LoadingStatus(frame: CGRectMake(0.0, 0.0, width, 40.0))
    }
    
    override init(frame: CGRect) {
        
        let loadingString: NSString = "Loading Photos…"
        
        let loadingFont = UIFont.boldSystemFontOfSize(17.0)
        
        let attrs: [String : AnyObject] = [NSFontAttributeName : loadingFont]

        let rect = loadingString.boundingRectWithSize(CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame)),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            attributes: attrs,
            context: nil)
        let labelSize = rect.size
        
        let centerX = floor((CGRectGetWidth(frame) / 2.0) - (labelSize.width / 2.0))
        let centerY = floor((CGRectGetHeight(frame) / 2.0) - (labelSize.height / 2.0))
        loadingLabel = UILabel(frame: CGRectMake(centerX, centerY, labelSize.width, labelSize.height))
        self.loadingLabel.backgroundColor = UIColor.clearColor()
        self.loadingLabel.textColor = UIColor.whiteColor()
        self.loadingLabel.text = loadingString as String
        self.loadingLabel.font = loadingFont
        
        progress = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        var progressFrame = self.progress.frame
        progressFrame.origin.x = centerX - CGRectGetWidth(progressFrame) - 8.0
        progressFrame.origin.y = centerY
        self.progress.frame = progressFrame
        
        self.addSubview(self.progress)
        self.addSubview(self.loadingLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willRemoveSubview(subview: UIView) {
        
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
        
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 0.0
            }) {finished in
                if finished {
                    self.removeFromSuperview()
                }
        }
    }
    
}