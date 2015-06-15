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

    public typealias FinishDelegate = (UIViewController, duration: Double) -> ()
    typealias CompletionCallback = () -> ()
    var didFinish: FinishDelegate?

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var restTimerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    public var workout : Workout!
    var restTimer: CountDownTimer!
    var workTimer: Timer!

    public override func viewDidLoad() {
        super.viewDidLoad()
        setTextLabels(workout)
        initializeTimer()
    }

    public func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        self.workout = workout
        self.didFinish = finishDelegate
        self.restTimer(restTimer)
    }

    func initializeTimer() {
        if restTimer == nil {
            setWorkoutTimeLabel()
            if let button = doneButton {
                button.hidden = false
            }
            startWorkTimer(workout)
        } else {
            if restTimer.isDone() {
                setWorkoutTimeLabel()
            } else {
                if let button = doneButton {
                    doneButton.hidden = true;
                }
            }
        }
    }

    public func startWorkTimer(workout: Workout) {
        workTimer = Timer(callback: updateWorkTime)
    }

    func setTextLabels(workout: Workout) {
        taskLabel.text = workout.workoutName
    }

    func setWorkoutTimeLabel() {
        timeLabel.tintColor = UIColor.whiteColor()
        timeLabel.text = "Workout time:"
    }

    @IBAction func done(sender: AnyObject) {
        workTimer.stop();
        self.didFinish!(self, duration: workTimer.duration())
    }

    private func restTimer(timer: CountDownTimer?) {
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
            if doneButton != nil {
                doneButton.hidden = false
            }
            restTimer.stop()
            timeLabel.text = "Workout time:"
            restTimerLabel.textColor = UIColor.whiteColor()
            startWorkTimer(workout)
        }
    }

    public func updateWorkTime(timer: Timer) {
        let (min, sec) = timer.elapsedTime()
        restTimerLabel.text = Timer.timeAsString(min, sec: sec)
    }

    @IBAction func info(sender: AnyObject) {
        performSegueWithIdentifier("infoSegue", sender: self)
    }

    public func isRestTimerLabelVisible() -> Bool {
        return restTimerLabel.hidden
    }

    public func restTimerLabelText() -> String? {
        return restTimerLabel.text
    }

    public func isTimeLabelVisible() -> Bool {
        return timeLabel.hidden
    }

    public func timeLabelText() -> String? {
        return timeLabel.text
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepareForSeque \(segue.identifier)")
        if segue.identifier == "infoSegue" {
            let infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.initWith(workout)
        }
    }

    public class func showVideo(segue: UIStoryboardSegue, workout: Workout) {
        if segue.identifier == "videoSegue" {
            println(workout)
            let videoURL = NSBundle.mainBundle().URLForResource(workout.videoUrl, withExtension: nil)
            let videoViewController = segue.destinationViewController as! AVPlayerViewController
            videoViewController.player = AVPlayer(URL: videoURL)
        }
    }

    public class func infoView(segue: UIStoryboardSegue, workout: Workout) {
        if segue.identifier == "infoSegue" {
            let infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.initWith(workout)
        }
    }

}
