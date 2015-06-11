//
//  IntervalViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 10/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

/**
Controls a interval based workout

*/
public class IntervalViewController: BaseWorkoutController {

    @IBOutlet weak var durationLabel: UILabel!
    var intervalWorkout : IntervalWorkout!
    var countDownTimer: CountDownTimer!

    public override func viewDidLoad() {
        super.viewDidLoad()
        //durationLabel.text = intervalWorkout.duration.stringValue
    }

    public override func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, restTimer: restTimer, finishDelegate: finishDelegate)
        intervalWorkout = workout as! IntervalWorkout
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
            //self.didFinish!(self, duration: intervalWorkout.workoutDuration.)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        BaseWorkoutController.showVideo(segue, workout: workout)
    }
    
}
