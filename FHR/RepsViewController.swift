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
    var restTimer: Timer!
    var workTimer: Timer!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var restTimerLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.workoutName()
        repsLabel.text = workout.repititions.stringValue
        descLabel.text = workout.desc()
        imageView.image = UIImage(data: workout.image())
        doneButton.hidden = true;
        if restTimer == nil {
            doneButton.hidden = false
            workTimer = Timer(callback: updateWorkTime)
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
            restTimerLabel.text = Timer.timeAsString(min, sec: sec)
        } else {
            restTimerLabel.hidden = true
            doneButton.hidden = false
            restTimer.stop()
            workTimer = Timer(callback: updateWorkTime)
        }
    }

    public func updateWorkTime(timer: Timer) {
        // Noop
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
