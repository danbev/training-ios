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
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!

    private lazy var coreDataStack = CoreDataStack()
    private let tableCell = "tableCell"
    private var workoutService: WorkoutService!
    private var tasks = [WorkoutProtocol]()
    private var restTimer: Timer!
    private var workoutTimer: Timer!
    private var preparedForSeque = false
    private var runtimeWorkout: RuntimeWorkout!

    private var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

    private func readSettings() {
        RuntimeWorkout.readIgnoredCategories()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
        progressView.progressTintColor = UIColor.greenColor()
        readSettings()
        loadLastWorkout()
        updateTitle()
    }

    private func loadLastWorkout() {
        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())
    }

    private func updateTitle() {
        let category = runtimeWorkout!.category()
        navItem.title = category
        startButton.setTitle("Start \(category)", forState: UIControlState.Normal)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let workoutTime = workoutTimer?.duration() ?? 0.0
        if runtimeWorkout.currentUserWorkout != nil {
            workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTime, done: runtimeWorkout.currentUserWorkout.done)
        }
    }

    public func updateTime(timer: Timer) {
        if timerLabel.hidden == true {
            timerLabel.hidden = false
        }
        let (min, sec) = timer.elapsedTime()
        if (min == 0 && sec < 10) {
            timerLabel.textColor = UIColor.orangeColor()
        }
        timerLabel.text = Timer.timeAsString(min, sec: sec)
        if (min == 0 && sec <= 0) {
            timer.stop()
            if !preparedForSeque {
                transition()
            }
        }
    }

    public func updateWorkoutTime(timer: Timer) {
        counter++;
    }

    private func clearWorkoutTasks() {
        for (i, t) in enumerate(tasks) {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: i, inSection: 0))
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell?.userInteractionEnabled = true
        }
        tasks.removeAll(keepCapacity: false)
        tableView.reloadData()
    }

    @IBAction func startWorkout(sender: UIButton) {
        startButton.hidden = true
        progressView.setProgress(0, animated: false)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        clearWorkoutTasks()
        let workoutDuration = RuntimeWorkout.readDurationSetting()
        println("workout duration = \(workoutDuration)")

        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())

        if runtimeWorkout.lastUserWorkout != nil {
            if runtimeWorkout.lastUserWorkout!.done.boolValue {
                workoutTimer = Timer(callback: updateWorkoutTime, countDown: workoutDuration)
                startNewUserWorkout(runtimeWorkout.lastUserWorkout!)
            } else {
                println("last user workout was not completed!. WorkoutTime=\(runtimeWorkout.lastUserWorkout!.duration)")
                workoutTimer = Timer(callback: updateWorkoutTime, countDown: runtimeWorkout.lastUserWorkout!.duration)
                if let workouts = runtimeWorkout.lastUserWorkout?.workouts {
                    for (index, w) in enumerate(workouts) {
                        tasks.append(w as! Workout)
                        tableView.reloadData()
                        if index != 0 {
                            checkmark(index)
                        }
                    }
                }
                tableView.reloadData()
            }
        } else {
            startNewUserWorkout(nil)
            self.workoutTimer = Timer(callback: updateWorkoutTime, countDown: workoutDuration)
        }
        navItem.title = runtimeWorkout.category()
    }

    private func checkmark(index: Int) -> UITableViewCell {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))!
        cell.userInteractionEnabled = false
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        cell.tintColor = UIColor.greenColor()
        return cell
    }

    private func startNewUserWorkout(lastUserWorkout: UserWorkout?) {
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: workoutService.newUserWorkout(lastUserWorkout, ignoredCategories: RuntimeWorkout.readIgnoredCategories()),
            lastUserWorkout: lastUserWorkout)
        addWorkoutToTable(runtimeWorkout.currentUserWorkout.workouts[0] as! Workout)
    }

    @IBAction func addWorkout(sender: AnyObject) {
        println("add a new workout...")
    }

    @IBAction func settingsButton(sender: AnyObject) {
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
        performSegue(tasks[indexPath.row])
    }

    private func transition() {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        performSegue(tasks[0])
    }

    private func performSegue(workout: WorkoutProtocol) {
        switch workout.type() {
        case .Reps:
            performSegueWithIdentifier("repsSegue", sender: self)
        case .Timed:
            performSegueWithIdentifier("durationSegue", sender: self)
        case .Interval:
            println("interval task...")
        case .Prebens:
            performSegueWithIdentifier("prebensSegue", sender: self)
        }
    }

    /**
    Prepares the transistion from the main view to the workout task details view.

    :param: segue the UIStoryboardSeque that was called
    */
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        preparedForSeque = true;
        if segue.identifier == "settings" {
            let settingsController = segue.destinationViewController as! SettingViewController
            settingsController.currentUserWorkout = runtimeWorkout.currentUserWorkout
        } else {
            let indexPath = tableView.indexPathForSelectedRow()!
            let task = tasks[indexPath.row]
            let workout = tasks[indexPath.row] as! Workout
            self.workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: workout, workoutTime: workoutTimer.duration())
            if segue.identifier == "repsSegue" {
                let taskViewController = segue.destinationViewController as! RepsViewController
                taskViewController.workout = workout as! RepsWorkout
                taskViewController.currentUserWorkout = runtimeWorkout.currentUserWorkout
                taskViewController.restTimer(restTimer)
                taskViewController.didFinish = {
                    [unowned self] controller, duration in
                    self.finishedWorkout(indexPath, workout: workout, duration: duration)
                }
            } else if segue.identifier == "durationSegue" {
                let taskViewController = segue.destinationViewController as! DurationViewController
                taskViewController.workout = workout as! DurationWorkout
                taskViewController.currentUserWorkout = runtimeWorkout.currentUserWorkout
                taskViewController.restTimer(restTimer)
                taskViewController.didFinish = {
                    [unowned self] controller, duration in
                    self.finishedWorkout(indexPath, workout: workout, duration: duration)
                }
            } else if segue.identifier == "prebensSegue" {
                let prebensViewController = segue.destinationViewController as! PrebensViewController
                prebensViewController.workout = workout as! PrebensWorkout
                prebensViewController.currentUserWorkout = runtimeWorkout.currentUserWorkout
                prebensViewController.restTimer(restTimer)
                prebensViewController.didFinish = {
                    [unowned self] controller, duration in
                    self.finishedWorkout(indexPath, workout: workout, duration: duration)
                }
            }
        }
    }

    private func finishedWorkout(indexPath: NSIndexPath, workout: Workout, duration: Double) {
        preparedForSeque = false;
        println("Finished workout \(workout.name()), duration=\(duration)")
        timerLabel.textColor = UIColor.whiteColor()
        var totalTime = workoutTimer.elapsedTime()
        println("Elapsed time \(totalTime.min):\(totalTime.sec)")
        let currentUserWorkout = workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: workout, workoutTime: workoutTimer.duration())
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout)
        if restTimer != nil {
            restTimer.stop()
        }
        dismissViewControllerAnimated(true, completion: nil)

        checkmark(indexPath.row)
        tableView.reloadData()

        if totalTime.min != 0 {
            restLabel.hidden = false
            restTimer = Timer(callback: updateTime, countDown: workout.restTime().doubleValue)
            let settings = RuntimeWorkout.settings()
            if let workout = workoutService.fetchWorkout(runtimeWorkout.category(), currentUserWorkout: runtimeWorkout.currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout, weights: settings.weights, dryGround: settings.dryGround) {
                tasks.insert(workout, atIndex: 0)
                tableView.reloadData()
                tableView.moveRowAtIndexPath(NSIndexPath(forRow: tasks.count - 1, inSection: 0), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                cell.userInteractionEnabled = true
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                tableView.reloadData()
            } else {
                println("There are no more workouts for category \(runtimeWorkout.category())")
                stopWorkout()
            }
        } else {
            let elapsedTime = workoutTimer.elapsedTime()
            println("Workout time completed \(Timer.timeAsString(elapsedTime.min, sec: elapsedTime.sec)).")
            stopWorkout()
        }
    }

    private func stopWorkout() {
        let currentUserWorkout = workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTimer.duration(), done: true)
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout)
        workoutTimer.stop()
        if restTimer != nil {
            restTimer.stop()
        }
        timerLabel.hidden = true
        restLabel.hidden = true
        progressView.setProgress(1.0, animated: false)
        startButton.hidden = false
        startButton.setTitle("Start \(runtimeWorkout.category())", forState: UIControlState.Normal)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.greenColor()]
    }

    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        readSettings()
        updateTitle()
    }

}

