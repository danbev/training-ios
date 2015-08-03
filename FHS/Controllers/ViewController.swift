//
//  ViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 14/09/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

/**
* Main view controller for workout tasks.
*/
public class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!

    private lazy var coreDataStack = CoreDataStack(modelName: "FHS", storeNames: ["FHS"])
    private let tableCell = "tableCell"
    private var workoutService: WorkoutService!
    private var userService: UserService!
    private var tasks = [Workout]()
    private var restTimer: CountDownTimer!
    private var workoutTimer: CountDownTimer!
    private var preparedForSeque = false
    private var runtimeWorkout: RuntimeWorkout!
    private var audioWarning = AudioWarning.instance
    private var bgQueue = NSOperationQueue()
    private var settings: Settings!
    private let greenColor = UIColor(red: 0.0/255, green: 200.0/255, blue: 0.0/255, alpha: 1.0)
    private var interruptedWorkout = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
        userService = UserService.newUserService()

        progressView.progressTintColor = greenColor
        loadLastWorkout()
        updateTitle()
        settings = Settings.settings()
        timerLabel.textColor = UIColor.orangeColor()
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
        /* TODO: update this with call to UserService
        if runtimeWorkout.currentUserWorkout != nil {
            workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTime, done: runtimeWorkout.currentUserWorkout.done)
        }
        */
    }

    public func updateTime(timer: CountDownTimer) {
        if timerLabel.hidden == true {
            timerLabel.hidden = false
        }
        let (min, sec, fra) = timer.elapsedTime()
        if min == 0 && sec <= 3 && fra < 5 {
            audioWarning.play()
        }
        timerLabel.text = CountDownTimer.timeAsString(min, sec, fra)
        if min == 0 && sec == 0 && fra <= 0 {
            timer.stop()
            if !preparedForSeque {
                transition()
            }
        }
    }

    public func updateWorkoutTime(timer: CountDownTimer) {
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
        cancelButton.hidden = false
        progressView.setProgress(0, animated: false)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        clearWorkoutTasks()
        let workoutDuration = settings.duration
        debugPrintln("workout duration = \(workoutDuration)")

        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())

        if runtimeWorkout.lastUserWorkout != nil {
            if runtimeWorkout.lastUserWorkout!.done.boolValue {
                workoutTimer = CountDownTimer(callback: updateWorkoutTime, countDown: workoutDuration)
                startNewUserWorkout(runtimeWorkout.lastUserWorkout!)
            } else {
                debugPrintln("last user workout was not completed!. WorkoutTime=\(runtimeWorkout.lastUserWorkout!.duration) workoutDuration=\(workoutDuration)")
                interruptedWorkout = true
                workoutTimer = CountDownTimer(callback: updateWorkoutTime, countDown: workoutDuration - runtimeWorkout.lastUserWorkout!.duration)
                if let workoutInfos = runtimeWorkout.lastUserWorkout?.workouts {
                    let count = workoutInfos.count - 1
                    for index in stride(from: count, through: 0, by: -1) {
                        let workoutInfo = workoutInfos[index] as! WorkoutInfo
                        let workout = workoutService.fetchWorkout(workoutInfo.workoutName)!
                        tasks.append(workout)
                        tableView.reloadData()
                        if index != count {
                            checkmark(count - index)
                        }
                    }
                }
                tableView.reloadData()
            }
        } else {
            startNewUserWorkout(nil)
            self.workoutTimer = CountDownTimer(callback: updateWorkoutTime, countDown: workoutDuration)
        }
        navItem.title = runtimeWorkout.category()
    }

    private func checkmark(index: Int) -> UITableViewCell {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))!
        cell.userInteractionEnabled = false
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        cell.tintColor = greenColor
        return cell
    }

    private func startNewUserWorkout(lastUserWorkout: UserWorkout?) {
        /*
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: workoutService.newUserWorkout(lastUserWorkout, settings: settings),
            lastUserWorkout: lastUserWorkout)
        let workoutInfo = runtimeWorkout.currentUserWorkout.workouts[0] as! WorkoutInfo
        if let workout = workoutService.fetchWorkout(workoutInfo.workoutName) {
            addWorkoutToTable(workout)
        } else {
            debugPrintln("Could not find workout: \(workoutInfo.workoutName) in current workout database")
        }
        */
    }

    @IBAction func addWorkout(sender: AnyObject) {
        performSegueWithIdentifier("addSegue", sender: self)
    }

    @IBAction func settingsButton(sender: AnyObject) {
    }
    
    public func addWorkoutToTable(workout: Workout) {
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
        cell.textLabel!.text = task.workoutName
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

    private func performSegue(workout: Workout) {
        let type = WorkoutType(rawValue: workout.type)!
        switch type {
        case .Reps:
            performSegueWithIdentifier("repsSegue", sender: self)
        case .Timed:
            performSegueWithIdentifier("durationSegue", sender: self)
        case .Interval:
            performSegueWithIdentifier("intervalSegue", sender: self)
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
        } else if segue.identifier == "addSegue" {
            let addController = segue.destinationViewController as! AddWorkoutViewController
            //addController.setWorkoutService(workoutService)
        } else {
            let indexPath = tableView.indexPathForSelectedRow()!
            let workout = tasks[indexPath.row]
            //workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: workout, workoutTime: workoutTimer.duration())
            let baseViewController = segue.destinationViewController as! BaseWorkoutController
            let userWorkouts = workoutService.fetchUserWorkouts(workout.workoutName)
            baseViewController.initWith(workout, userWorkouts: userWorkouts, restTimer: restTimer) {
                [unowned self] controller, duration in
                self.finishedWorkout(indexPath, workout: workout, duration: duration)
            }
        }
    }

    private func finishedWorkout(indexPath: NSIndexPath, workout: Workout, duration: Double) {
        preparedForSeque = false;
        debugPrintln("Finished workout \(workout.name), duration=\(duration)")
        var totalTime = workoutTimer.elapsedTime()
        debugPrintln("Elapsed time \(totalTime.min):\(totalTime.sec)")
        //let currentUserWorkout = workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: workout, workoutTime: workoutTimer.duration())
        //runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout)
        if restTimer != nil {
            restTimer.stop()
        }
        dismissViewControllerAnimated(true, completion: nil)

        checkmark(indexPath.row)
        tableView.reloadData()

        if totalTime.min != 0 || interruptedWorkout {
            interruptedWorkout = false
            restLabel.hidden = false
            restTimer = CountDownTimer(callback: updateTime, countDown: workout.restTime.doubleValue)
            if !runtimeWorkout.warmupCompleted(settings.warmup, numberOfWarmups: 2) {
                let warmup = workoutService.fetchWarmup(runtimeWorkout.currentUserWorkout)
                insertNewWorkout(warmup!)
            } else {
                if let workout = workoutService.fetchWorkout(runtimeWorkout.category(), currentUserWorkout: runtimeWorkout.currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout, weights: settings.weights, dryGround: settings.dryGround) {
                    insertNewWorkout(workout)
                } else {
                    debugPrintln("There are no more workouts for category \(runtimeWorkout.category())")
                    stopWorkout()
                }
            }
        } else {
            let elapsedTime = workoutTimer.elapsedTime()
            debugPrintln("Workout time completed \(CountDownTimer.timeAsString(elapsedTime.min, elapsedTime.sec, elapsedTime.fra)).")
            stopWorkout()
        }
    }

    private func insertNewWorkout(workout: Workout) {
        tasks.insert(workout, atIndex: 0)
        tableView.reloadData()
        tableView.moveRowAtIndexPath(NSIndexPath(forRow: tasks.count - 1, inSection: 0), toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
        cell.userInteractionEnabled = true
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        tableView.reloadData()
    }

    private func stopWorkout() {
        /*
        let currentUserWorkout = workoutService.updateUserWorkout(runtimeWorkout.currentUserWorkout.id, optionalWorkout: nil, workoutTime: workoutTimer.duration(), done: true)
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout)
        */
        workoutTimer.stop()
        if restTimer != nil {
            restTimer.stop()
        }
        timerLabel.hidden = true
        restLabel.hidden = true
        progressView.setProgress(1.0, animated: false)
        startButton.hidden = false
        startButton.setTitle("Start \(runtimeWorkout.category())", forState: UIControlState.Normal)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:greenColor]
        cancelButton.hidden = true
    }

    func checkmarkAll() {
        for i in 0..<tasks.count {
            checkmark(i)
        }
    }

    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        let settingsViewController = sender.sourceViewController as! SettingViewController
        settings = Settings.settings()
        updateTitle()
    }

    @IBAction func cancelWorkout(sender: AnyObject) {
        stopWorkout()
        checkmarkAll()
    }

    var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 60000.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

}

