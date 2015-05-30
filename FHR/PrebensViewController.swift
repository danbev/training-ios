//
//  PrebensViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 27/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//
import Foundation
import UIKit
import Foundation

public class PrebensViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prebensLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    typealias FinishDelegate = (PrebensViewController, duration: Double) -> ()
    var didFinish: FinishDelegate?
    var workout : PrebensWorkout!
    var currentUserWorkout : UserWorkout!
    var restTimer: CountDownTimer!
    var workTimer: CountDownTimer!
    private var tasks = [RepsWorkout]()
    public let tableCell = "tableCell"

    public override func viewDidLoad() {
        super.viewDidLoad()
        prebensLabel.text = workout.modelWorkoutName
        descriptionText.text = workout.modelDescription
        descriptionText.textColor = UIColor.whiteColor()

        for w in workout.workouts {
            tasks.append(w as! RepsWorkout)
        }
        tableView.reloadData()
        if restTimer == nil {
            println("rest timer is nil. Creating a new worktimer.")
            restTimeLabel.hidden = true
            doneButton.hidden = false
            workTimer = CountDownTimer(callback: updateWorkTime)
        } else {
            if restTimer.isDone() {
                println("rest timer is done. Creating a new worktimer.")
                timeLabel.hidden = true
                workTimer = CountDownTimer(callback: updateWorkTime)
            } else {
                println("rest timer is not done. Hiding the time label")
                timeLabel.hidden = false
                restTimeLabel.hidden = false
            }
        }
    }

    /**
    Handle taps of items in the workout task list.

    :param: tableView the UITableView which was tapped
    :param: indexPath the NSIndexPath identifying the cell to being tapped
    */
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow()!;
        let task = tasks[indexPath.row]
    }

    /**
    Returns the number of rows in the table view section.

    :param: tableView the UITableView for which the number of rows should be returned
    :param: section the selected section. For example this could be the warmup section or main section.
    :returns: Int the number of rows in the table view section
    */
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    /**
    Returns the UITableViewCell for the passed-in indexPath.

    Is called for every visible row in the table view that comes into view.

    :param: tableView the UITableView from which the UITableViewCell should be retrieved
    :param: indexPath the NSIndexPath identifying the cell to be returned
    :returns: UITableCellView the table cell view matching the indexPath
    */
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        let task = tasks[indexPath.row]
        cell.textLabel!.text = "\(task.repititions) \(task.workoutName())"
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell;
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
                timeLabel.textColor = UIColor.orangeColor()
            }
            timeLabel.text = CountDownTimer.timeAsString(min, sec: sec)
        } else {
            doneButton.hidden = false
            restTimer.stop()
            restTimeLabel.hidden = true
            timeLabel.hidden = true
            workTimer = CountDownTimer(callback: updateWorkTime)
        }
    }

    @IBAction func infoButton(sender: AnyObject) {
        let alert = UIAlertController(title: workout.modelWorkoutName, message: workout.modelDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    public func updateWorkTime(timer: CountDownTimer) {
        // Noop
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func done(sender: AnyObject) {
        if workTimer != nil {
            workTimer.stop();
        } else {
            //TODO: this must be sorted out. Some race condition seems to be in play.
            workTimer = CountDownTimer(callback: updateWorkTime)
        }
        self.didFinish!(self, duration: workTimer.duration())
    }
}
