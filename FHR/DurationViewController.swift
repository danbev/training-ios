//
//  DurationViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 07/03/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation

/**
Controlls a duration based workout

*/
public class DurationViewController: UIViewController {

    typealias FinishDelegate = (DurationViewController, duration: Double) -> ()
    var didFinish: FinishDelegate?
    var restTimer: Timer!
    // define a closure that starts this workout.
    public var workout : DurationWorkout!
    var currentUserWorkout: UserWorkout!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak public var timeLabel: UILabel!

    @IBOutlet weak var restTimerLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.modelWorkoutName
        durationLabel.text = workout.duration.stringValue
        descLabel.text = workout.desc()
        imageView.image = UIImage(data: workout.image())

        if restTimer != nil && restTimer.isDone() {
            timeLabel.hidden = true
        } else {
            timeLabel.hidden = false
        }
    }

    public func restTimer(timer: Timer?) {
        if let t = timer {
            restTimer = Timer.fromTimer(t, callback: updateTime)
        }
    }

    public func updateTime(timer: Timer) {
        let (min, sec) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            if (min == 0 && sec < 10) {
                restTimerLabel.textColor = UIColor.orangeColor()
            }
            restTimerLabel.text = Timer.timeAsString(min, sec: sec)
        } else {
            restTimerLabel.textColor = UIColor.whiteColor()
            restTimer.stop()
            timeLabel.text = "Workout time"
            restTimer = Timer(callback: updateTime2, countDown: workout.duration.doubleValue)
        }
    }

    public func updateTime2(timer: Timer) {
        let (min, sec) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            restTimerLabel.text = Timer.timeAsString(min, sec: sec)
        } else {
            timer.stop()
            self.didFinish!(self, duration: workout.duration.doubleValue)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func done(sender: AnyObject) {
    }
}