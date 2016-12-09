//
//  InfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 04/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

open class InfoViewController: UIViewController {

    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var noVideoLabel: UILabel!
    open var workout : WorkoutProtocol!

    open override func viewDidLoad() {
        super.viewDidLoad()
        setTextLabels(workout)
    }

    open func initWith(_ workout: WorkoutProtocol) {
        self.workout = workout
    }

    func setTextLabels(_ workout: WorkoutProtocol) {
        workoutNameLabel.text = workout.workoutName()
        descriptionLabel.text = workout.workoutDescription()
    }

    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "videoSegue" {
            if let videoUrl = workout.videoUrl() {
                let videoViewController = segue.destination as! AVPlayerViewController
                videoViewController.view.backgroundColor = UIColor.darkGray
                let dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)
                if videoUrl.range(of: "video")?.lowerBound == videoUrl.startIndex {
                    if let remoteUrl = URL(string: videoUrl, relativeTo: URL(string: dict!.value(forKey: "VideoUrl") as! String)) {
                        print("remote url:\(remoteUrl)")
                        videoViewController.player = AVPlayer(url: remoteUrl)
                    }
                } else {
                    print("local url:\(videoUrl)")
                    videoViewController.player = AVPlayer(url: URL(fileURLWithPath: videoUrl))
                }
            } else {
                container.isHidden = true
                noVideoLabel.isHidden = false
            }
        }
    }

}
