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

    @IBOutlet weak var restWorkoutLabel: UILabel!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    var intervalWorkout : IntervalWorkout!
    var countDownTimer: CountDownTimer!
    var intervals: Int!
    var intervalCounter: Int = 0
    private static let white = UIColor.whiteColor()
    private static let orange = UIColor.orangeColor()

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutLabel.text = intervalWorkout.work.workoutName
        restWorkoutLabel.text = intervalWorkout.rest.workoutName
    }

    public override func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, restTimer: restTimer, finishDelegate: finishDelegate)
        intervalWorkout = workout as! IntervalWorkout
        intervals = intervalWorkout.intervals.integerValue
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func startWorkTimer(workout: Workout) {
        let intervalWorkout = workout as! IntervalWorkout
        labelsWorkoutState()
        countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work.duration.doubleValue)
    }

    private func labelsWorkoutState() {
        workoutLabel.textColor = IntervalViewController.orange
        workoutTimeLabel.textColor = IntervalViewController.orange
        restWorkoutLabel.textColor = IntervalViewController.white
        restTimeLabel.textColor = IntervalViewController.white
    }

    private func labelsRestState() {
        workoutLabel.textColor = IntervalViewController.white
        workoutTimeLabel.textColor = IntervalViewController.white
        restWorkoutLabel.textColor = IntervalViewController.orange
        restTimeLabel.textColor = IntervalViewController.orange
    }

    private func labelsDoneState() {
        workoutLabel.textColor = IntervalViewController.white
        workoutTimeLabel.textColor = IntervalViewController.white
        restWorkoutLabel.textColor = IntervalViewController.white
        restTimeLabel.textColor = IntervalViewController.white
    }

    public func workDurationCallback(timer: CountDownTimer) {
        let (min, sec) = timer.elapsedTime()
        println("workout duration: \(min):\(sec)")
        if min >= 0 && sec > 0 {
            workoutTimeLabel.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            workoutTimeLabel.text = "00:00"
            timer.stop()
            labelsRestState()
            countDownTimer = CountDownTimer(callback: restDurationCallback, countDown: intervalWorkout.rest.duration.doubleValue)
            intervalCounter++
        }
    }

    public func restDurationCallback(timer: CountDownTimer) {
        let (min, sec) = timer.elapsedTime()
        println("rest duration: \(min):\(sec)")
        if min >= 0 && sec > 0 {
            restTimeLabel.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            restTimeLabel.text = "00:00"
            timer.stop()
            if intervalCounter < intervalWorkout.intervals.integerValue {
                labelsWorkoutState()
                countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work.duration.doubleValue)
            } else {
                labelsDoneState()
                let duration = intervalWorkout.work.duration.integerValue * intervals + intervalWorkout.rest.duration.integerValue * intervals
                println("Number of workouts was reached. Duration=\(duration)")
                self.didFinish!(self, duration: Double(duration))
            }
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        BaseWorkoutController.showVideo(segue, workout: workout)
    }
    
}
