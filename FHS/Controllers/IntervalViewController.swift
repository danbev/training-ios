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
open class IntervalViewController: BaseWorkoutController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var intervalsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var workoutTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var intervalTitleLabel: UILabel!
    fileprivate let tableCell = "intervalCell"
    var intervalWorkout : IntervalWorkoutProtocol!
    var countDownTimer: CountDownTimer!
    var intervals: Int!
    var intervalCounter: Int = 1
    fileprivate static let white = UIColor.white
    fileprivate static let orange = UIColor.orange
    var workouts = [DurationWorkoutProtocol]()

    open override func viewDidLoad() {
        super.viewDidLoad()
        intervalsLabel.text = String(intervals)
        tableView.reloadData()
    }

    open override func initWith(_ workout: WorkoutProtocol, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: @escaping FinishDelegate) {
        super.initWith(workout, userWorkouts: userWorkouts, restTimer: restTimer, finishDelegate: finishDelegate)
        initWorkout(workout)
    }

    fileprivate func initWorkout(_ workout: WorkoutProtocol) {
        intervalWorkout = workout as! IntervalWorkoutProtocol
        intervals = intervalWorkout.intervals().intValue
        workouts.append(intervalWorkout.work())
        workouts.append(intervalWorkout.rest())
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCell, for: indexPath)
        let workout = workouts[indexPath.row]
        cell.textLabel!.text = workout.workoutName()
        return cell;
    }

    open override func startWorkTimer(_ workout: WorkoutProtocol) {
        tableView.reloadData()
        timeLabel.isHidden = true
        restTimerLabel.isHidden = true
        intervalTitleLabel.isHidden = false
        intervalLabel.textColor = IntervalViewController.orange
        intervalLabel.text = "1"
        labelsWorkoutState()
        countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work().duration().doubleValue)
    }

    fileprivate func labelsWorkoutState() {
        let work = workCell()!
        work.textLabel?.textColor = IntervalViewController.orange
        work.detailTextLabel?.textColor = IntervalViewController.orange
        work.tintColor = IntervalViewController.orange

        let rest = restCell()!
        rest.textLabel?.textColor = IntervalViewController.white
        rest.detailTextLabel?.textColor = IntervalViewController.white
        rest.tintColor = IntervalViewController.white
    }

    fileprivate func labelsRestState() {
        let work = workCell()!
        work.textLabel?.textColor = IntervalViewController.white
        work.detailTextLabel?.textColor = IntervalViewController.white
        work.tintColor = IntervalViewController.white

        let rest = restCell()!
        rest.textLabel?.textColor = IntervalViewController.orange
        rest.detailTextLabel?.textColor = IntervalViewController.orange
        rest.tintColor = IntervalViewController.orange
    }

    fileprivate func labelsDoneState() {
        let work = workCell()!
        work.textLabel?.textColor = IntervalViewController.white
        work.detailTextLabel?.textColor = IntervalViewController.white
        work.tintColor = IntervalViewController.white

        let rest = restCell()!
        rest.textLabel?.textColor = IntervalViewController.white
        rest.detailTextLabel?.textColor = IntervalViewController.white
        rest.tintColor = IntervalViewController.white
    }

    fileprivate func workCell() -> UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: 0, section: 0))
    }

    fileprivate func restCell() -> UITableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: 1, section: 0))
    }

    open func workDurationCallback(_ timer: CountDownTimer) {
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

    open func restDurationCallback(_ timer: CountDownTimer) {
        let (min, sec, fra) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            restCell()?.detailTextLabel?.text = CountDownTimer.timeAsString(min, sec, fra)
            if  min == 0 && sec <= 3 && fra < 5 {
                audioWarning.play()
            }
        } else {
            restCell()?.detailTextLabel?.text = "00:00:00"
            timer.stop()
            if intervalCounter < intervalWorkout.intervals().intValue {
                labelsWorkoutState()
                intervalCounter += 1
                intervalLabel.text = String(intervalCounter)
                countDownTimer = CountDownTimer(callback: workDurationCallback, countDown: intervalWorkout.work().duration().doubleValue)
            } else {
                labelsDoneState()
                let duration = intervalWorkout.work().duration().intValue * intervals + intervalWorkout.rest().duration().intValue * intervals
                self.didFinish!(self, Double(duration))
            }
        }
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let infoController = segue.destination as! InfoViewController
            if let indexPath = sender as? IndexPath {
                let workout = workouts[indexPath.row]
                infoController.initWith(workout)
            } else {
                infoController.initWith(intervalWorkout)
            }
        }
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "infoSegue", sender: indexPath)
    }

}
