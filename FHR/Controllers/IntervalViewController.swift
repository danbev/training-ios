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
    private let tableCell = "intervalCell"
    var intervalWorkout : IntervalWorkout!
    var countDownTimer: CountDownTimer!
    var intervals: Int!
    var intervalCounter: Int = 0
    private static let white = UIColor.whiteColor()
    private static let orange = UIColor.orangeColor()
    var workouts = [DurationWorkout]()

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        intervalsLabel.text = String(intervals)
    }

    public override func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, restTimer: restTimer, finishDelegate: finishDelegate)
        intervalWorkout = workout as! IntervalWorkout
        intervals = intervalWorkout.intervals.integerValue
        workouts.append(intervalWorkout.work)
        workouts.append(intervalWorkout.rest)
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
        cell.textLabel!.text = workout.workoutName
        return cell;
    }

    public override func startWorkTimer(workout: Workout) {
        let intervalWorkout = workout as! IntervalWorkout
        timeLabel.hidden = true
        restTimerLabel.hidden = true
        labelsWorkoutState()
        countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work.duration.doubleValue)
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
        let (min, sec) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            workCell()?.detailTextLabel?.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            workCell()?.detailTextLabel?.text = "00:00"
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
            restCell()?.detailTextLabel?.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            restCell()?.detailTextLabel?.text = "00:00"
            timer.stop()
            if intervalCounter < intervalWorkout.intervals.integerValue {
                labelsWorkoutState()
                countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work.duration.doubleValue)
            } else {
                labelsDoneState()
                let duration = intervalWorkout.work.duration.integerValue * intervals + intervalWorkout.rest.duration.integerValue * intervals
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
            println(sender)
            if sender is Workout {
                infoController.initWith(sender as! Workout)
            } else {
                infoController.initWith(intervalWorkout)
            }
        }
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let workout = workouts[indexPath.row]
        performSegueWithIdentifier("infoSegue", sender: workout)
    }

}
