//
//  ViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 14/09/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import CoreData

/**
* Main view controller for workout tasks.
*/
public class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    public let tableCell = "tableCell"
    private lazy var coreDataStack = CoreDataStack()
    private var workoutService: WorkoutService!
    private var tasks = [WorkoutProtocol]()
    private var userWorkout: UserWorkout!

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
    }

    public func updateTime(timer: Timer) {
        timerLabel.hidden = false
        let (min, sec) = timer.elapsedTime()
        timerLabel.text = Timer.timeAsString(min, sec: sec)
        counter++;
    }

    var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 1000.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

    @IBAction func startWorkout(sender: UIButton) {
        startButton.hidden = true
        if let lastUserWorkout = workoutService.fetchLatestUserWorkout() {
            userWorkout = lastUserWorkout
            Timer(countDown: 45, callback: updateTime)
            if let warmup = workoutService.fetchWarmup(lastUserWorkout) {
                addWorkoutToTable(warmup)
            }
            // populate the table with the already completed workouts
            // update the time with the time remaining
        } else {
            if let warmup = workoutService.fetchWarmup() {
                Timer(countDown: 45, callback: updateTime)
                addWorkoutToTable(warmup)
                let id = NSUUID().UUIDString
                userWorkout = workoutService.saveUserWorkout(id, category: .UpperBody, workout: warmup)
            }
        }
    }

    @IBAction func addWorkout(sender: AnyObject) {
        println("add a new workout...")
    }
    
    public func addWorkoutToTable(workout: WorkoutProtocol) {
        tasks.append(workout)
        tableView.reloadData()
    }

    public func loadTask(category: Category) {
        if let workout = workoutService.fetchWorkout(category, userWorkout: userWorkout) {
            tasks.append(workout)
            tableView.reloadData()
        } else {
            println("There are no more workouts!!!")
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as UITableViewCell
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.workoutName()
        return cell;
    }

    /**
    Handle taps of items in the workout task list.

    :param: tableView the UITableView which was tapped
    :param: indexPath the NSIndexPath identifying the cell to being tapped
    */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    }

    /**
    Prepares the transistion from the main view to the workout task details view.

    :param: segue the UIStoryboardSeque that was called
    */
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow()!;
        let task = tasks[indexPath.row]
        switch task.type() {
        case .Reps:
            let taskViewController = segue.destinationViewController as RepsViewController
            let workout = tasks[tableView.indexPathForSelectedRow()!.row] as Workout
            taskViewController.workout = workout.reps
            taskViewController.didFinish = {
                [unowned self] controller in
                // saveCompletedTask(workout)
                self.workoutService.updateUserWorkout(self.userWorkout.id, workout: workout)

                self.dismissViewControllerAnimated(true, completion: nil)

                let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
                cell.userInteractionEnabled = false
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.tintColor = UIColor.greenColor()

                let t = self.tasks.removeAtIndex(indexPath.row)
                self.tasks.append(t)
                self.tableView.moveRowAtIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: self.tasks.count - 1, inSection: 0))

                self.loadTask(Category.UpperBody)
            }
        case .Timed:
            println("timed task...")
        case .Interval:
            println("interval task...")
        }
    }

}

