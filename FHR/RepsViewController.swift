//
//  RepsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation

/**
Controlls a Reps based workout

*/
public class RepsViewController: UIViewController {

    typealias FinishDelegate = (RepsViewController, duration: Double) -> ()
    var didFinish: FinishDelegate?
    var workout : RepsWorkout!
    var currentUserWorkout : UserWorkout!
    var restTimer: CountDownTimer!
    var workTimer: Timer!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var restTimerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.workoutName()
        repsLabel.text = workout.repititions.stringValue
        descLabel.text = workout.desc()
        imageView.image = UIImage(data: workout.image())
        doneButton.hidden = true;
        if restTimer == nil {
            //restTimerLabel.hidden = true
            timeLabel.text = "Workout time:"
            doneButton.hidden = false
            totalTime.hidden = false
            workTimer = Timer(callback: updateWorkTime)
        } else {
            if restTimer.isDone() {
                timeLabel.text = "Workout time:"
            }
        }
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
            //restTimerLabel.hidden = true
            //timeLabel.hidden = true
            timeLabel.text = "Workout time:"
            restTimerLabel.textColor = UIColor.whiteColor()
            totalTime.hidden = false
            workTimer = Timer(callback: updateWorkTime)
        }
    }

    public func updateWorkTime(timer: Timer) {
        let (min, sec) = timer.elapsedTime()
        println("\(min):\(sec)")
        //totalTime.text = Timer.timeAsString(min, sec: sec)
        restTimerLabel.text = Timer.timeAsString(min, sec: sec)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func done(sender: AnyObject) {
        workTimer.stop();
        println("duration of reps workout=\(workTimer.duration())")
        self.didFinish!(self, duration: workTimer.duration())
    }
}
