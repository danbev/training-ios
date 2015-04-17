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
    @IBOutlet weak var completedLabel: UILabel!
    public let tableCell = "tableCell"
    //private let workoutDuration: Double = 2700
    private let workoutDuration: Double = 20
    private lazy var coreDataStack = CoreDataStack()
    private var workoutService: WorkoutService!
    private var tasks = [WorkoutProtocol]()
    private var currentUserWorkout: UserWorkout!
    private var lastUserWorkout: UserWorkout?
    private var timer: Timer!
    private var workoutTimer: Timer!
    private var category: Category!

    private var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
        progressView.progressTintColor = UIColor.greenColor()

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(Category.UpperBody.rawValue, forKey: "category")
        println(defaults.objectForKey("category"))
    }

    public func updateTime(timer: Timer) {
        if timerLabel.hidden == true {
            timerLabel.hidden = false
        }
        let (min, sec) = timer.elapsedTime()
        timerLabel.text = Timer.timeAsString(min, sec: sec)
    }

    public func updateWorkoutTime(timer: Timer) {
        counter++;
    }

    @IBAction func startWorkout(sender: UIButton) {
        if completedLabel.hidden == false {
            completedLabel.hidden = true
        }
        if tasks.count > 0 {
            tasks.removeAll(keepCapacity: true)
            self.tableView.reloadData()
        }
        startButton.hidden = true
        progressView.setProgress(0, animated: false)
        lastUserWorkout = workoutService.fetchLatestUserWorkout()
        if lastUserWorkout != nil {
            if lastUserWorkout!.done.boolValue {
                startNewUserWorkout(lastUserWorkout!)
            } else {
                println("last user workout was not completed!")
            }
            // populate the table with the already completed workouts
            // update the time with the time remaining
        } else {
            if let warmup = workoutService.fetchWarmup() {
                self.workoutTimer = Timer(callback: updateWorkoutTime, countDown: workoutDuration)
                addWorkoutToTable(warmup)
                let id = NSUUID().UUIDString
                category = .UpperBody
                currentUserWorkout = workoutService.saveUserWorkout(id, category: category, workout: warmup)
            }
        }
    }

    private func startNewUserWorkout(lastUserWorkout: UserWorkout) {
        category = Category(rawValue: lastUserWorkout.category)!.next()
        println("Category for new workout: \(category.rawValue)")
        if let warmup = workoutService.fetchWarmup(lastUserWorkout) {
            addWorkoutToTable(warmup)
            let id = NSUUID().UUIDString
            currentUserWorkout = workoutService.saveUserWorkout(id, category: category, workout: warmup)
        } else {
            println("could not find a warmup task!!")
        }
    }

    @IBAction func addWorkout(sender: AnyObject) {
        println("add a new workout...")
    }
    
    public func addWorkoutToTable(workout: WorkoutProtocol) {
        tasks.append(workout)
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.workoutName()
        return cell;
    }

    /**
    Handle taps of items in the workout task list.

    :param: tableView the UITableView which was tapped
    :param: indexPath the NSIndexPath identifying the cell to being tapped
    */
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow()!;
        let task = tasks[indexPath.row]
        switch task.type() {
        case .Reps:
            performSegueWithIdentifier("repsSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
        case .Timed:
            performSegueWithIdentifier("durationSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
        case .Interval:
            println("interval task...")
        }
    }

    /**
    Prepares the transistion from the main view to the workout task details view.

    :param: segue the UIStoryboardSeque that was called
    */
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = tableView.indexPathForSelectedRow()!;
        let task = tasks[indexPath.row]
        if segue.identifier == "repsSegue" {
            let taskViewController = segue.destinationViewController as! RepsViewController
            let workout = tasks[tableView.indexPathForSelectedRow()!.row] as! Workout
            taskViewController.workout = workout.reps
            taskViewController.restTimer(timer)
            taskViewController.didFinish = {
                [unowned self] controller, duration in
                self.finishedWorkout(indexPath, workout: workout, duration: duration)
            }
        } else if segue.identifier == "durationSegue" {
            let taskViewController = segue.destinationViewController as! DurationViewController
            let workout = tasks[tableView.indexPathForSelectedRow()!.row] as! Workout
            taskViewController.workout = workout.timed
            taskViewController.restTimer(timer)
            taskViewController.didFinish = {
                [unowned self] controller, duration in
                self.finishedWorkout(indexPath, workout: workout, duration: duration)
            }
        }
    }

    private func finishedWorkout(indexPath: NSIndexPath, workout: Workout, duration: Double) {
        println("Finished workout \(workout.name()), duration=\(duration)")
        var totalTimeInMins = workoutTimer.elapsedTime().min
        println("Total time=\(totalTimeInMins)")
        self.workoutService.updateUserWorkout(self.currentUserWorkout.id, optionalWorkout: workout)
        if self.timer != nil {
            self.timer.stop()
        }
        self.dismissViewControllerAnimated(true, completion: nil)

        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0))!
        cell.userInteractionEnabled = false
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        cell.tintColor = UIColor.greenColor()
        self.tableView.reloadData()

        if totalTimeInMins != 0 {
            self.timer = Timer(callback: self.updateTime, countDown: workout.restTime().doubleValue)
            if let workout = self.workoutService.fetchWorkout(category.rawValue, currentUserWorkout: self.currentUserWorkout, lastUserWorkout: self.lastUserWorkout) {
                println("Fetched workout \(workout.name())")
                self.tasks.insert(workout, atIndex: 0)
                self.tableView.reloadData()
                self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: self.tasks.count - 1, inSection: 0), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                cell.userInteractionEnabled = true
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                self.tableView.reloadData()
            } else {
                workoutService.updateUserWorkout(currentUserWorkout.id, optionalWorkout: nil, done: true)
                timer.stop()
                timerLabel.hidden = true
                startButton.hidden = false
                println("There are no more workouts!!!")
            }
        } else {
            let elapsedTime = workoutTimer.elapsedTime()
            workoutService.updateUserWorkout(currentUserWorkout.id, optionalWorkout: nil, done: true)
            println("Workout time completed \(Timer.timeAsString(elapsedTime.min, sec: elapsedTime.sec)).")
            workoutTimer.stop()
            timerLabel.hidden = true
            progressView.setProgress(1.0, animated: true)
            completedLabel.hidden = false
            startButton.hidden = false
        }
    }

}

