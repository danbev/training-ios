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
public class IntervalViewController: BaseWorkoutController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var intervalsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var intervalTitleLabel: UILabel!
    private let tableCell = "intervalCell"
    var intervalWorkout : IntervalWorkoutProtocol!
    var countDownTimer: CountDownTimer!
    var intervals: Int!
    var intervalCounter: Int = 1
    private static let white = UIColor.whiteColor()
    private static let orange = UIColor.orangeColor()
    var workouts = [DurationWorkoutProtocol]()

    public override func viewDidLoad() {
        super.viewDidLoad()
        intervalsLabel.text = String(intervals)
        tableView.reloadData()
    }

    public override func initWith(workout: WorkoutProtocol, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, userWorkouts: userWorkouts, restTimer: restTimer, finishDelegate: finishDelegate)
        initWorkout(workout)
    }

    private func initWorkout(workout: WorkoutProtocol) {
        intervalWorkout = workout as! IntervalWorkoutProtocol
        intervals = intervalWorkout.intervals().integerValue
        workouts.append(intervalWorkout.work())
        workouts.append(intervalWorkout.rest())
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        let workout = workouts[indexPath.row]
        cell.textLabel!.text = workout.workoutName()
        return cell;
    }

    public override func startWorkTimer(workout: WorkoutProtocol) {
        tableView.reloadData()
        timeLabel.hidden = true
        restTimerLabel.hidden = true
        intervalTitleLabel.hidden = false
        intervalLabel.textColor = IntervalViewController.orange
        intervalLabel.text = "1"
        labelsWorkoutState()
        countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work().duration().doubleValue)
    }

    private func labelsWorkoutState() {
        let work = workCell()!
        work.textLabel?.textColor = IntervalViewController.orange
        work.detailTextLabel?.textColor = IntervalViewController.orange
        work.tintColor = IntervalViewController.orange

        let rest = restCell()!
        rest.textLabel?.textColor = IntervalViewController.white
        rest.detailTextLabel?.textColor = IntervalViewController.white
        rest.tintColor = IntervalViewController.white
    }

    private func labelsRestState() {
        let work = workCell()!
        work.textLabel?.textColor = IntervalViewController.white
        work.detailTextLabel?.textColor = IntervalViewController.white
        work.tintColor = IntervalViewController.white

        let rest = restCell()!
        rest.textLabel?.textColor = IntervalViewController.orange
        rest.detailTextLabel?.textColor = IntervalViewController.orange
        rest.tintColor = IntervalViewController.orange
    }

    private func labelsDoneState() {
        let work = workCell()!
        work.textLabel?.textColor = IntervalViewController.white
        work.detailTextLabel?.textColor = IntervalViewController.white
        work.tintColor = IntervalViewController.white

        let rest = restCell()!
        rest.textLabel?.textColor = IntervalViewController.white
        rest.detailTextLabel?.textColor = IntervalViewController.white
        rest.tintColor = IntervalViewController.white
    }

    private func workCell() -> UITableViewCell? {
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
    }

    private func restCell() -> UITableViewCell? {
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
    }

    public func workDurationCallback(timer: CountDownTimer) {
        let (min, sec, fra) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            workCell()?.detailTextLabel?.text = CountDownTimer.timeAsString(min, sec, fra)
            if  min == 0 && sec <= 3 && fra < 5 {
                audioWarning.play()
            }
        } else {
            workCell()?.detailTextLabel?.text = "00:00:00"
            timer.stop()
            labelsRestState()
            countDownTimer = CountDownTimer(callback: restDurationCallback, countDown: intervalWorkout.rest().duration().doubleValue)
        }
    }

    public func restDurationCallback(timer: CountDownTimer) {
        let (min, sec, fra) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            restCell()?.detailTextLabel?.text = CountDownTimer.timeAsString(min, sec, fra)
            if  min == 0 && sec <= 3 && fra < 5 {
                audioWarning.play()
            }
        } else {
            restCell()?.detailTextLabel?.text = "00:00:00"
            timer.stop()
            if intervalCounter < intervalWorkout.intervals().integerValue {
                labelsWorkoutState()
                intervalCounter++
                intervalLabel.text = String(intervalCounter)
                countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work().duration().doubleValue)
            } else {
                labelsDoneState()
                let duration = intervalWorkout.work().duration().integerValue * intervals + intervalWorkout.rest().duration().integerValue * intervals
                self.didFinish!(self, duration: Double(duration))
            }
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "infoSegue" {
            let infoController = segue.destinationViewController as! InfoViewController
            if let indexPath = tableView.indexPathForSelectedRow() {
                let workout = workouts[indexPath.row]
                infoController.initWith(workout)
            } else {
                infoController.initWith(intervalWorkout)
            }
        }
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let workout = workouts[indexPath.row]
        performSegueWithIdentifier("infoSegue", sender: self)
    }

}
