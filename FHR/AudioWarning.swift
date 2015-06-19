//
//  AutoWarning.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioWarning {
    public static let instance = AudioWarning()
    var audioPlayer: AVAudioPlayer!

    init() {
        let soundFile = NSBundle.mainBundle().URLForResource("bleep", withExtension: "wav")
        var error: NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: soundFile, error: &error)
    }

    public func play() {
        if !audioPlayer.playing {
            audioPlayer.play()
        }
    }

}
