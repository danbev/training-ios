//
//  AutoWarning.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import AVFoundation

open class AudioWarning {
    open static let instance = AudioWarning()
    var audioPlayer: AVAudioPlayer!

    init() {
        let soundFile = Bundle.main.url(forResource: "bleep", withExtension: "wav")
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundFile!)
        } catch let error1 as NSError {
            error = error1
            debugPrint(error)
            audioPlayer = nil
        }
    }

    open func play() {
        if !audioPlayer.isPlaying {
            audioPlayer.play()
        }
    }

}
