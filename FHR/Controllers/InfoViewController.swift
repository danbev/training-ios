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

public class InfoViewController: UIViewController {

    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var noVideoLabel: UILabel!
    public var workout : Workout!

    public override func viewDidLoad() {
        super.viewDidLoad()
        setTextLabels(workout)
    }

    public func initWith(workout: Workout) {
        self.workout = workout
    }

    func setTextLabels(workout: Workout) {
        workoutNameLabel.text = workout.workoutName
        descriptionLabel.text = workout.workoutDescription
    }

    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "videoSegue" {
            if let videoUrl = workout.videoUrl {
                println("vidoeUrl: \(videoUrl)")
                var url = NSBundle.mainBundle().URLForResource(videoUrl, withExtension: nil)
                if url == nil {
                    println("Is fileUrl: \(url?.fileURL)")
                    url = NSURL.fileURLWithPath(videoUrl)
                }
                let videoViewController = segue.destinationViewController as! AVPlayerViewController
                videoViewController.player = AVPlayer(URL: url)
            } else {
                container.hidden = true
                noVideoLabel.hidden = false
            }
        }
    }

}
