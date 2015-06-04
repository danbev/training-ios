//
//  BaseWorkoutController.swift
//  FHR
//
//  Created by Daniel Bevenius on 04/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class BaseWorkoutController: UIViewController {

    typealias FinishDelegate = (UIViewController, duration: Double) -> ()
    var didFinish: FinishDelegate?

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var restTimerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var restTimer: CountDownTimer!
    var workTimer: Timer!
    var workout : Workout!

    public override func viewDidLoad() {
        super.viewDidLoad()
        setTextLabels(workout)
        initializeTimer()
    }

    func initializeTimer() {
        if restTimer == nil {
            setWorkoutTimeLabel()
            doneButton.hidden = false
            workTimer = Timer(callback: updateWorkTime)
        } else {
            if restTimer.isDone() {
                setWorkoutTimeLabel()
            } else {
                doneButton.hidden = true;
            }
        }
    }

    func setTextLabels(workout: Workout) {
        taskLabel.text = workout.workoutName()
        descLabel.text = workout.desc()
    }

    func setWorkoutTimeLabel() {
        restTimerLabel.textColor = UIColor.whiteColor()
        restTimerLabel.text = "Workout time:"
    }

    public func updateWorkTime(timer: Timer) {
        let (min, sec) = timer.elapsedTime()
        restTimerLabel.text = Timer.timeAsString(min, sec: sec)
    }

    @IBAction func done(sender: AnyObject) {
        workTimer.stop();
        println("duration of prebens=\(workTimer.duration())")
        self.didFinish!(self, duration: workTimer.duration())
    }

    public func restTimer(timer: CountDownTimer?) {
        if let t = timer {
            restTimer = CountDownTimer.fromTimer(t, callback: updateTime)
        }
    }

    public func updateTime(timer: CountDownTimer) {
        let (min, sec) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            if (min == 0 && sec < 10) {
                restTimerLabel.textColor = UIColor.orangeColor()
            }
            restTimerLabel.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            doneButton.hidden = false
            restTimer.stop()
            timeLabel.text = "Workout time:"
            restTimerLabel.textColor = UIColor.whiteColor()
            workTimer = Timer(callback: updateWorkTime)
        }
    }

    public class func showVideo(segue: UIStoryboardSegue, workout: Workout) {
        if segue.identifier == "videoSegue" {
            let videoURL = NSBundle.mainBundle().URLForResource(workout.videoUrl, withExtension: nil)
            let videoViewController = segue.destinationViewController as! AVPlayerViewController
            videoViewController.player = AVPlayer(URL: videoURL)
        }
    }

}
