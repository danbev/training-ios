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
    public var workout : WorkoutManagedObject!

    public override func viewDidLoad() {
        super.viewDidLoad()
        setTextLabels(workout)
    }

    public func initWith(workout: WorkoutManagedObject) {
        self.workout = workout
    }

    func setTextLabels(workout: WorkoutManagedObject) {
        workoutNameLabel.text = workout.workoutName
        descriptionLabel.text = workout.workoutDescription
    }

    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "videoSegue" {
            if let videoUrl = workout.videoUrl {
                let videoViewController = segue.destinationViewController as! AVPlayerViewController
                videoViewController.view.backgroundColor = UIColor.darkGrayColor()
                var dict = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Info", ofType: "plist")!)
                if videoUrl.rangeOfString("video")?.startIndex == videoUrl.startIndex {
                    if let remoteUrl = NSURL(string: videoUrl, relativeToURL: NSURL(string: dict!.valueForKey("VideoUrl") as! String)) {
                        println("remote url:\(remoteUrl)")
                        videoViewController.player = AVPlayer.playerWithURL(remoteUrl) as! AVPlayer
                    }
                } else {
                    println("local url:\(videoUrl)")
                    videoViewController.player = AVPlayer(URL: NSURL.fileURLWithPath(videoUrl))
                }
            } else {
                container.hidden = true
                noVideoLabel.hidden = false
            }
        }
    }

}
