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
    @IBOutlet weak var previousWorkTimeLabel: UILabel!
    @IBOutlet weak var previousWorkTime: UILabel!
    let audioWarning = AudioWarning.instance
    let bgQueue = NSOperationQueue()

    public var workout : Workout!
    var restTimer: CountDownTimer!
    var userWorkouts: WorkoutInfo?
    var restTimerFromMain: CountDownTimer?
    var workTimer: Timer!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.workoutName
        restTimerLabel.textColor = UIColor.orangeColor()
        // the timer callback should not be called before this view is loaded.
        restTimer(restTimerFromMain)
        initializeTimer()
    }

    public func initWith(workout: Workout, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        self.workout = workout
        self.didFinish = finishDelegate
        self.userWorkouts = userWorkouts
        restTimerFromMain = restTimer
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

    func setWorkoutTimeLabel() {
        timeLabel.textColor = UIColor.whiteColor()
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
        let (min, sec, fra) = timer.elapsedTime()
        if min == 0 && sec == 0 && fra == 0 {
            restTimer.stop()
            timeLabel.text = "Workout time:"
            startWorkTimer(workout)
            showLastWorkoutTime()
            if doneButton != nil {
                doneButton.hidden = false
            }
        } else {
            restTimerLabel.text = CountDownTimer.timeAsString(min, sec, fra)
            if  min == 0 && sec <= 3 && fra < 5 {
                bgQueue.addOperationWithBlock() {
                    self.audioWarning.play()
                }
            }
        }
    }

    private func showLastWorkoutTime() {
        if let last = userWorkouts {
            previousWorkTimeLabel?.hidden = false
            previousWorkTime?.hidden = false
            let (min, sec, fra) = Timer.elapsedTime(last.duration)
            previousWorkTime?.text = Timer.timeAsString(min, sec: sec, fra: fra)
        }
    }

    public func updateWorkTime(timer: Timer) {
        let (min, sec, fra) = timer.elapsedTime()
        restTimerLabel.text = Timer.timeAsString(min, sec: sec, fra: fra)
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
        if segue.identifier == "infoSegue" {
            let infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.initWith(workout)
        }
    }

    public class func infoView(segue: UIStoryboardSegue, workout: Workout) {
        if segue.identifier == "infoSegue" {
            let infoViewController = segue.destinationViewController as! InfoViewController
            infoViewController.initWith(workout)
        }
    }

}
