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

    public var durationWorkout : DurationWorkout!
    var currentUserWorkout: UserWorkout!
    @IBOutlet weak var durationLabel: UILabel!
    var countDownTimer: CountDownTimer!


    public override func viewDidLoad() {
        super.viewDidLoad()
        durationWorkout = workout as! DurationWorkout
        durationLabel.text = durationWorkout.duration.stringValue
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func startWorkTimer(workout: Workout) {
        let dw = workout as! DurationWorkout
        countDownTimer = CountDownTimer(callback: durationCallback, countDown: dw.duration.doubleValue)
    }

    public func durationCallback(timer: CountDownTimer) {
        let (min, sec) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            restTimerLabel.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            timer.stop()
            self.didFinish!(self, duration: durationWorkout.duration.doubleValue)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        BaseWorkoutController.showVideo(segue, workout: workout)
    }

}