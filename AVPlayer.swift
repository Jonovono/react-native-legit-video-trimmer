//
//  AVPlayer.swift
//  react-native-legit-video-trimmer
//
//  Created by Andrii Novoselskyi on 28.08.2020.
//

import AVFoundation

extension AVPlayer {

    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
