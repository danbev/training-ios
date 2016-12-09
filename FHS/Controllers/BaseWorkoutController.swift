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

open class BaseWorkoutController: UIViewController {

    public typealias FinishDelegate = (UIViewController, _ duration: Double) -> ()
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

    open var workout : WorkoutProtocol!
    var restTimer: CountDownTimer!
    var userWorkouts: WorkoutInfo?
    var restTimerFromMain: CountDownTimer?
    var workTimer: Timer!

    open override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.workoutName()
        restTimerLabel.textColor = UIColor.orange
        // the timer callback should not be called before this view is loaded.
        restTimer(restTimerFromMain)
        initializeTimer()
    }

    open func initWith(_ workout: WorkoutProtocol, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: @escaping FinishDelegate) {
        self.workout = workout
        self.didFinish = finishDelegate
        self.userWorkouts = userWorkouts
        restTimerFromMain = restTimer
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("entered background")
    }

    func initializeTimer() {
        if restTimer == nil {
            setWorkoutTimeLabel()
            if let button = doneButton {
                button.isHidden = false
            }
            startWorkTimer(workout)
        } else {
            if restTimer.isDone() {
                setWorkoutTimeLabel()
            } else {
                if let _ = doneButton {
                    doneButton.isHidden = true;
                }
            }
        }
    }

    open func startWorkTimer(_ workout: WorkoutProtocol) {
        workTimer = Timer(callback: updateWorkTime)
    }

    func setWorkoutTimeLabel() {
        timeLabel.textColor = UIColor.white
        timeLabel.text = "Workout time:"
    }

    @IBAction func done(_ sender: AnyObject) {
        workTimer.stop();
        self.didFinish!(self, workTimer.duration())
    }

    fileprivate func restTimer(_ timer: CountDownTimer?) {
        if let t = timer {
            restTimer = CountDownTimer.fromTimer(t, callback: updateTime)
        }
    }

    open func updateTime(_ timer: CountDownTimer) {
        let (min, sec, fra) = timer.elapsedTime()
        if min == 0 && sec == 0 && fra == 0 {
            restTimer.stop()
            timeLabel.text = "Workout time:"
            startWorkTimer(workout)
            showLastWorkoutTime()
            if doneButton != nil {
                doneButton.isHidden = false
            }
        } else {
            restTimerLabel.text = CountDownTimer.timeAsString(min, sec, fra)
            if  min == 0 && sec <= 3 && fra < 5 {
                self.audioWarning.play()
            }
        }
    }

    fileprivate func showLastWorkoutTime() {
        if let last = userWorkouts {
            if last.duration > 0.0 {
                let (min, sec, fra) = Timer.elapsedTime(last.duration)
                previousWorkTimeLabel?.isHidden = false
                previousWorkTime?.isHidden = false
                previousWorkTime?.text = Timer.timeAsString(min, sec: sec, fra: fra)
            }
        }
    }

    open func updateWorkTime(_ timer: Timer) {
        let (min, sec, fra) = timer.elapsedTime()
        restTimerLabel.text = Timer.timeAsString(min, sec: sec, fra: fra)
    }

    @IBAction func info(_ sender: AnyObject) {
        performSegue(withIdentifier: "infoSegue", sender: self)
    }

    open func isRestTimerLabelVisible() -> Bool {
        return restTimerLabel.isHidden
    }

    open func restTimerLabelText() -> String? {
        return restTimerLabel.text
    }

    open func isTimeLabelVisible() -> Bool {
        return timeLabel.isHidden
    }

    open func timeLabelText() -> String? {
        return timeLabel.text
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let infoViewController = segue.destination as! InfoViewController
            infoViewController.initWith(workout)
        }
    }

    open class func infoView(_ segue: UIStoryboardSegue, workout: Workout) {
        if segue.identifier == "infoSegue" {
            let infoViewController = segue.destination as! InfoViewController
            infoViewController.initWith(workout)
        }
    }

}
