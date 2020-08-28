//
//  RNVideoTrimmerViewManager.swift
//  react-native-legit-video-trimmer
//
//  Created by Andrii Novoselskyi on 27.08.2020.
//

import Foundation

@objc(VideoTrimmerViewManager)
class VideoTrimmerViewManager: RCTViewManager {
    
    override func view() -> UIView! {
        return LegitVideoTrimmerView()
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }
}
