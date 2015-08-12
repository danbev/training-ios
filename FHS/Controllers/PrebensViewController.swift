// //  PrebensViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 27/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//
import Foundation
import UIKit
import Foundation

public class PrebensViewController: BaseWorkoutController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prebensLabel: UILabel!
    var prebensWorkout : PrebensWorkoutProtocol!
    var tasks = [RepsWorkoutProtocol]()
    public let tableCell = "tableCell"

    public override func viewDidLoad() {
        super.viewDidLoad()
        prebensWorkout = workout as! PrebensWorkoutProtocol
        for w in prebensWorkout.workouts() {
            tasks.append(w)
        }
        tableView.reloadData()
    }

    public override func initWith(workout: WorkoutProtocol, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, userWorkouts: userWorkouts, restTimer: restTimer, finishDelegate: finishDelegate)
        prebensWorkout = workout as! PrebensWorkoutProtocol
    }

    /**
    Handle taps of items in the workout task list.

    :param: tableView the UITableView which was tapped
    :param: indexPath the NSIndexPath identifying the cell to being tapped
    */
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("tableView row selected = \(indexPath)")
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "infoSegue" {
            let infoController = segue.destinationViewController as! InfoViewController
            if let indexPath = tableView.indexPathForSelectedRow() {
                infoController.initWith(tasks[indexPath.row])
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            } else {
                infoController.initWith(prebensWorkout)
            }
        }
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let workout = tasks[indexPath.row]
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        performSegueWithIdentifier("infoSegue", sender: self)
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
        cell.textLabel!.text = task.workoutName()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = task.repititions().stringValue
        return cell;
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
