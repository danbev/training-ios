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
    //@IBOutlet weak var workoutTypeLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    public let tableCell = "tableCell"
    //private let workoutDuration: Double = 2700
    //private let workoutDuration: Double = 70
    private var workoutDuration: Double!
    private lazy var coreDataStack = CoreDataStack()
    private var workoutService: WorkoutService!
    private var tasks = [WorkoutProtocol]()

    private var currentUserWorkout: UserWorkout!
    private var lastUserWorkout: UserWorkout?

    private var timer: Timer!
    private var workoutTimer: Timer!
    private var category: WorkoutCategory!
    private var userDefaults: NSUserDefaults!
    private var ignoredCategories: Set<WorkoutCategory> = Set()
    private var preparedForSeque = false
    private var weights: Bool!
    private var indoor: Bool!

    private var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

    private func readSettings() {
        ignoredCategories.removeAll(keepCapacity: true)
        if !enabled(WorkoutCategory.UpperBody.rawValue) {
            ignoredCategories.insert(WorkoutCategory.UpperBody)
        }
        if !enabled(WorkoutCategory.LowerBody.rawValue) {
            ignoredCategories.insert(WorkoutCategory.LowerBody)
        }
        if !enabled(WorkoutCategory.Cardio.rawValue) {
            ignoredCategories.insert(WorkoutCategory.Cardio)
        }
        weights = enabled("weights")
        indoor = enabled("indoor")
    }

    func enabled(keyName: String) -> Bool {
        if let value = userDefaults!.objectForKey(keyName) as? Bool {
            return value
        }
        return true;
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        userDefaults = NSUserDefaults.standardUserDefaults()
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
        progressView.progressTintColor = UIColor.greenColor()
        updateTitle()
    }

    private func updateTitle() {
        var workoutType: String
        println("currentUserWorkout.done = \(currentUserWorkout?.done)")
        if currentUserWorkout == nil {
            workoutType = WorkoutCategory.Warmup.next(ignoredCategories).rawValue
        } else if currentUserWorkout != nil {
            if currentUserWorkout.done == false {
                workoutType = category.rawValue
            } else {
                workoutType = lastUserWorkout != nil ?
                    WorkoutCategory(rawValue: lastUserWorkout!.category)!.next(ignoredCategories).rawValue :
                    WorkoutCategory.Warmup.next(ignoredCategories).rawValue
            }
        } else {
            workoutType = WorkoutCategory.Warmup.next(ignoredCategories).rawValue
        }
        navItem.title = workoutType
        startButton.setTitle("Start \(workoutType)", forState: UIControlState.Normal)
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("View is appearing....")
        lastUserWorkout = workoutService.fetchLatestUserWorkout()
        readSettings()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let workoutTime = workoutTimer?.duration() ?? 0.0
        if currentUserWorkout != nil {
            println("View is disapearing....\(currentUserWorkout.done)")
            workoutService.updateUserWorkout(currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTime, done: currentUserWorkout.done)
        }
    }

    func readWorkoutDuration() -> Double {
        if let value = userDefaults!.objectForKey("workoutDuration") as? Int {
            return Double(value * 60)
        }
        return Double(2700)
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

    @IBAction func startWorkout(sender: UIButton) {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        if completedLabel.hidden == false {
            completedLabel.hidden = true
        }
        for (i, t) in enumerate(tasks) {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: i, inSection: 0))
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell?.userInteractionEnabled = true
            //tasks.removeAtIndex(i)
        }
        tasks.removeAll(keepCapacity: false)
        tableView.reloadData()
        workoutDuration = readWorkoutDuration()
        println("workout duration = \(workoutDuration)")

        readSettings()
        startButton.hidden = true
        progressView.setProgress(0, animated: false)
        lastUserWorkout = workoutService.fetchLatestUserWorkout()
        if lastUserWorkout != nil {
            if lastUserWorkout!.done.boolValue {
                self.workoutTimer = Timer(callback: updateWorkoutTime, countDown: workoutDuration)
                startNewUserWorkout(lastUserWorkout!)
            } else {
                //lastUserWorkout = workoutService.fetchLatestUserWorkout()
                currentUserWorkout = lastUserWorkout
                println("last user workout was not completed!. WorkoutTime=\(lastUserWorkout?.duration)")
                workoutTimer = Timer(callback: updateWorkoutTime, countDown: lastUserWorkout!.duration)
                category = WorkoutCategory(rawValue: lastUserWorkout!.category)
                if let workouts = lastUserWorkout?.workouts {
                    for (index, w) in enumerate(workouts) {
                        tasks.append(w as! Workout)
                        tableView.reloadData()
                        if index != 0 {
                            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))!
                            cell.userInteractionEnabled = false
                            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                            cell.tintColor = UIColor.greenColor()
                        }
                    }
                }
                tableView.reloadData()
            }
        } else {
            if let warmup = workoutService.fetchWarmup() {
                self.workoutTimer = Timer(callback: updateWorkoutTime, countDown: workoutDuration)
                addWorkoutToTable(warmup)
                let id = NSUUID().UUIDString
                category = WorkoutCategory.Warmup.next(ignoredCategories)
                currentUserWorkout = workoutService.saveUserWorkout(id, category: category, workout: warmup)
            }
        }
        navItem.title = category.rawValue
    }

    private func startNewUserWorkout(lastUserWorkout: UserWorkout) {
        category = WorkoutCategory(rawValue: lastUserWorkout.category)!.next(ignoredCategories)
        navItem.title = category.rawValue
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

    @IBAction func settingsButton(sender: AnyObject) {
        println("settings")
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
        case .Prebens:
            println("prebens task...")
            performSegueWithIdentifier("prebensSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
        }
    }

    private func transition() {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        let task = tasks[0]
        switch task.type() {
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
            settingsController.currentUserWorkout = currentUserWorkout
        } else {
            let indexPath = tableView.indexPathForSelectedRow()!
            let task = tasks[indexPath.row]
            let workout = tasks[indexPath.row] as! Workout
            self.workoutService.updateUserWorkout(self.currentUserWorkout.id, optionalWorkout: workout, workoutTime: workoutTimer.duration())
            if segue.identifier == "repsSegue" {
                let taskViewController = segue.destinationViewController as! RepsViewController
                taskViewController.workout = workout as! RepsWorkout
                taskViewController.currentUserWorkout = currentUserWorkout
                taskViewController.restTimer(timer)
                taskViewController.didFinish = {
                    [unowned self] controller, duration in
                    self.finishedWorkout(indexPath, workout: workout, duration: duration)
                }
            } else if segue.identifier == "durationSegue" {
                let taskViewController = segue.destinationViewController as! DurationViewController
                taskViewController.workout = workout as! DurationWorkout
                taskViewController.currentUserWorkout = currentUserWorkout
                taskViewController.restTimer(timer)
                taskViewController.didFinish = {
                    [unowned self] controller, duration in
                    self.finishedWorkout(indexPath, workout: workout, duration: duration)
                }
            } else if segue.identifier == "prebensSegue" {
                let prebensViewController = segue.destinationViewController as! PrebensViewController
                prebensViewController.workout = workout as! PrebensWorkout
                prebensViewController.currentUserWorkout = currentUserWorkout
                prebensViewController.restTimer(timer)
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
        // add workout time to saved user workout
        currentUserWorkout = workoutService.updateUserWorkout(self.currentUserWorkout.id, optionalWorkout: workout, workoutTime: workoutTimer.duration())
        if self.timer != nil {
            self.timer.stop()
        }
        self.dismissViewControllerAnimated(true, completion: nil)

        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0))!
        cell.userInteractionEnabled = false
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        cell.tintColor = UIColor.greenColor()
        self.tableView.reloadData()

        if totalTime.min != 0 {
            self.restLabel.hidden = false
            self.timer = Timer(callback: self.updateTime, countDown: workout.restTime().doubleValue)
            if let workout = self.workoutService.fetchWorkout(category.rawValue, currentUserWorkout: self.currentUserWorkout, lastUserWorkout: self.lastUserWorkout) {
                self.tasks.insert(workout, atIndex: 0)
                self.tableView.reloadData()
                self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: self.tasks.count - 1, inSection: 0), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                cell.userInteractionEnabled = true
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                self.tableView.reloadData()
            } else {
                currentUserWorkout = workoutService.updateUserWorkout(currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTimer.duration(), done: true)
                workoutTimer.stop()
                println("currentUserWorkout.done=\(currentUserWorkout.done)")
                timer.stop()
                timerLabel.hidden = true
                startButton.setTitle("Start \(category.next().rawValue)", forState: UIControlState.Normal)
                startButton.hidden = false
                restLabel.hidden = true
                navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.greenColor()]
                progressView.setProgress(1.0, animated: false)
                println("There are no more workouts for category \(category.rawValue)")
                startButton.setTitle("Start \(category.next().rawValue)", forState: UIControlState.Normal)
            }
        } else {
            let elapsedTime = workoutTimer.elapsedTime()
            currentUserWorkout = workoutService.updateUserWorkout(currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTimer.duration(), done: true)
            println("Workout time completed \(Timer.timeAsString(elapsedTime.min, sec: elapsedTime.sec)).")
            workoutTimer.stop()
            timerLabel.hidden = true
            restLabel.hidden = true
            progressView.setProgress(1.0, animated: false)
            completedLabel.hidden = false
            startButton.hidden = false
            startButton.setTitle("Start \(category.next().rawValue)", forState: UIControlState.Normal)
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.greenColor()]
        }
    }

    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        println("unwinding to main")
        readSettings()
        updateTitle()
    }

}

