//
//  DurationViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 07/03/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

/**
Controls a duration based workout

*/
public class DurationViewController: BaseWorkoutController {

    @IBOutlet weak var durationLabel: UILabel!
    var durationWorkout : DurationWorkout!
    var countDownTimer: CountDownTimer!

    public override func viewDidLoad() {
        super.viewDidLoad()
        durationLabel.text = durationWorkout.duration.stringValue
    }

    public override func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, restTimer: restTimer, finishDelegate: finishDelegate)
        durationWorkout = workout as! DurationWorkout
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func startWorkTimer(workout: Workout) {
        let dw = workout as! DurationWorkout
        countDownTimer = CountDownTimer(callback: durationCallback, countDown: dw.duration.doubleValue)
    }

    public func durationCallback(timer: CountDownTimer) {
        let (min, sec, fra) = timer.elapsedTime()
        if min == 0 && sec == 0 && fra == 0 {
            timer.stop()
            self.didFinish!(self, duration: durationWorkout.duration.doubleValue)
        } else {
            restTimerLabel.text = CountDownTimer.timeAsString(min, sec: sec, fra: fra)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}