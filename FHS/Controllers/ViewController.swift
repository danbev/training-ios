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
open class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!

    fileprivate let tableCell = "tableCell"
    fileprivate var workoutService: WorkoutService!
    fileprivate var tasks = [WorkoutProtocol]()
    fileprivate var restTimer: CountDownTimer!
    fileprivate var workoutTimer: CountDownTimer!
    fileprivate var preparedForSeque = false
    fileprivate var runtimeWorkout: RuntimeWorkout!
    fileprivate var audioWarning = AudioWarning.instance
    fileprivate var bgQueue = OperationQueue()
    fileprivate var settings: Settings!
    fileprivate let greenColor = UIColor(red: 0.0/255, green: 200.0/255, blue: 0.0/255, alpha: 1.0)
    fileprivate var interruptedWorkout = false
    fileprivate let userService = UserService.newUserService()

    open override func viewDidLoad() {
        super.viewDidLoad()
        settings = Settings.settings()
        progressView.progressTintColor = greenColor
        timerLabel.textColor = UIColor.orange
        let _ = CoreDataStack.copyStoreFromBundle("FHS")
        let _ = CoreDataStack.copyStoreFromBundle("Testing")
        initStores(settings.stores)
    }

    fileprivate func initStores(_ stores: [String]) {
        print("ViewController stores: \(stores)")
        let coreDataStack = CoreDataStack.storesFromBundle(stores, modelName: "FHS")
        workoutService = WorkoutService(coreDataStack: coreDataStack, userService: userService)
        workoutService.loadDataIfNeeded()
        loadLastWorkout()
        updateTitle()
    }

    fileprivate func loadLastWorkout() {
        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())
    }

    fileprivate func updateTitle() {
        let category = runtimeWorkout!.category()
        navItem.title = category
        startButton.setTitle("Start \(category)", for: UIControlState())
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settings = Settings.settings()
        if settings.stores != workoutService.stores() {

        }
        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())
        settings = Settings.settings()
        updateTitle()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let workoutTime = workoutTimer?.duration() ?? 0.0
        if runtimeWorkout.currentUserWorkout != nil {
            let _ = userService.updateUserWorkout(runtimeWorkout.currentUserWorkout).addToDuration(workoutTime).done(runtimeWorkout.currentUserWorkout.done).save()
        }
    }

    open func updateTime(_ timer: CountDownTimer) {
        if timerLabel.isHidden == true {
            timerLabel.isHidden = false
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

    open func updateWorkoutTime(_ timer: CountDownTimer) {
        counter += 1;
    }

    fileprivate func clearWorkoutTasks() {
        for (i, _) in tasks.enumerated() {
            let cell = tableView.cellForRow(at: IndexPath(item: i, section: 0))
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cell?.isUserInteractionEnabled = true
        }
        tasks.removeAll(keepingCapacity: false)
        tableView.reloadData()
    }

    @IBAction func startWorkout(_ sender: UIButton) {
        startButton.isHidden = true
        cancelButton.isHidden = false
        progressView.setProgress(0, animated: false)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        clearWorkoutTasks()
        let workoutDuration = settings.duration

        runtimeWorkout = RuntimeWorkout(lastUserWorkout: workoutService.fetchLatestUserWorkout())

        if runtimeWorkout.lastUserWorkout != nil {
            if runtimeWorkout.lastUserWorkout!.done {
                workoutTimer = CountDownTimer(callback: updateWorkoutTime, countDown: workoutDuration)
                startNewUserWorkout(runtimeWorkout.lastUserWorkout!)
            } else {
                debugPrint("last user workout was not completed!. WorkoutTime=\(runtimeWorkout.lastUserWorkout!.duration) workoutDuration=\(workoutDuration)")
                interruptedWorkout = true
                workoutTimer = CountDownTimer(callback: updateWorkoutTime, countDown: workoutDuration - runtimeWorkout.lastUserWorkout!.duration)
                if let workoutInfos = runtimeWorkout.lastUserWorkout?.workouts {
                    let count = workoutInfos.count - 1
                    for index in stride(from: count, through: 0, by: -1) {
                        let workoutInfo = workoutInfos[index] as! WorkoutInfo
                        if let workout = workoutService.fetchWorkoutProtocol(workoutInfo.name) {
                            tasks.append(workout)
                            tableView.reloadData()
                            if index != count {
                                let _ = checkmark(count - index)
                            }
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

    fileprivate func checkmark(_ index: Int) -> UITableViewCell {
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))!
        cell.isUserInteractionEnabled = false
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        cell.tintColor = greenColor
        return cell
    }

    fileprivate func startNewUserWorkout(_ lastUserWorkout: UserWorkout?) {
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: workoutService.newUserWorkout(lastUserWorkout, settings: settings),
            lastUserWorkout: lastUserWorkout)

        if let workout = runtimeWorkout.currentUserWorkout {
            let workoutInfo = workout.workouts[0] as! WorkoutInfo
            if let workout = workoutService.fetchWorkoutProtocol(workoutInfo.name) {
                addWorkoutToTable(workout)
            } else {
                debugPrint("Could not find workout: \(workoutInfo.name) in current workout database")
            }
        } else {
            debugPrint("Looks like there are no workout in the data store")
            stopWorkout()
        }
    }

    @IBAction func addWorkout(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "addSegue", sender: self)
    }

    @IBAction func settingsButton(_ sender: AnyObject) {
    }
    
    open func addWorkoutToTable(_ workout: WorkoutProtocol) {
        tasks.append(workout)
        tableView.reloadData()
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
    Returns the number of rows in the table view section.

    - parameter tableView: the UITableView for which the number of rows should be returned
    - parameter section: the selected section. For example this could be the warmup section or main section.
    - returns: Int the number of rows in the table view section
    */
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    /**
    Returns the UITableViewCell for the passed-in indexPath.
    
    Is called for every visible row in the table view that comes into view.

    - parameter tableView: the UITableView from which the UITableViewCell should be retrieved
    - parameter indexPath: the NSIndexPath identifying the cell to be returned
    - returns: UITableCellView the table cell view matching the indexPath
    */
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCell, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.workoutName()
        return cell;
    }

    /**
    Handle taps of items in the workout task list.

    - parameter tableView: the UITableView which was tapped
    - parameter indexPath: the NSIndexPath identifying the cell to being tapped
    */
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!;
        performSegue(tasks[indexPath.row])
    }

    fileprivate func transition() {
        let indexPath = IndexPath(item: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        performSegue(tasks[0])
    }

    fileprivate func performSegue(_ workout: WorkoutProtocol) {
        switch workout {
        case is RepsWorkout:
            self.performSegue(withIdentifier: "repsSegue", sender: self)
        case is DurationWorkout:
            self.performSegue(withIdentifier: "durationSegue", sender: self)
        case is IntervalWorkout:
            self.performSegue(withIdentifier: "intervalSegue", sender: self)
        case is PrebensWorkout:
            self.performSegue(withIdentifier: "prebensSegue", sender: self)
        default:
            debugPrint("No workout type for \(workout)")
        }
    }

    /**
    Prepares the transistion from the main view to the workout task details view.

    - parameter segue: the UIStoryboardSeque that was called
    */
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        preparedForSeque = true;
        if segue.identifier == "settings" {
            let settingsController = segue.destination as! SettingViewController
            settingsController.currentUserWorkout = runtimeWorkout.currentUserWorkout
        } else if segue.identifier == "addSegue" {
            let addController = segue.destination as! AddWorkoutViewController
            addController.setUserService(workoutService.getUserService())
        } else {
            let indexPath = tableView.indexPathForSelectedRow!
            let workout = tasks[indexPath.row]
            let _ = userService.updateUserWorkout(runtimeWorkout.currentUserWorkout).addWorkout(workout.name()).addToDuration(workoutTimer.duration()).save()
            let baseViewController = segue.destination as! BaseWorkoutController
            let workoutInfo = workoutService.fetchLatestPerformed(workout.workoutName())
            baseViewController.initWith(workout, userWorkouts: workoutInfo, restTimer: restTimer) {
                [unowned self] controller, duration in
                self.finishedWorkout(indexPath, workout: workout, duration: duration)
            }
        }
    }

    fileprivate func finishedWorkout(_ indexPath: IndexPath, workout: WorkoutProtocol, duration: Double) {
        preparedForSeque = false;
        let totalTime = workoutTimer.elapsedTime()
        let currentUserWorkout = userService.updateUserWorkout(runtimeWorkout.currentUserWorkout).addWorkout(workout.name()).addToDuration(workoutTimer.duration()).save()
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout)
        if restTimer != nil {
            restTimer.stop()
        }
        dismiss(animated: true, completion: nil)

        let _ = checkmark(indexPath.row)
        tableView.reloadData()

        if totalTime.min != 0 || interruptedWorkout {
            interruptedWorkout = false
            restLabel.isHidden = false
            restTimer = CountDownTimer(callback: updateTime, countDown: workout.restTime().doubleValue)
            if !runtimeWorkout.warmupCompleted(settings.warmup, numberOfWarmups: 2) {
                if let warmup = workoutService.fetchWarmupProtocol(runtimeWorkout.currentUserWorkout) {
                    insertNewWorkout(warmup)
                } else {
                    debugPrint("There are no more warmups")
                    stopWorkout()
                }
            } else {
                if let workout = workoutService.fetchWorkoutProtocol(runtimeWorkout.category(), currentUserWorkout: runtimeWorkout.currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout, weights: settings.weights, dryGround: settings.dryGround) {
                    insertNewWorkout(workout)
                } else {
                    debugPrint("There are no more workouts for category \(runtimeWorkout.category())")
                    stopWorkout()
                }
            }
        } else {
            let elapsedTime = workoutTimer.elapsedTime()
            debugPrint("Workout time completed \(CountDownTimer.timeAsString(elapsedTime.min, elapsedTime.sec, elapsedTime.fra)).")
            stopWorkout()
        }
    }

    fileprivate func insertNewWorkout(_ workout: WorkoutProtocol) {
        tasks.insert(workout, at: 0)
        tableView.reloadData()
        tableView.moveRow(at: IndexPath(row: tasks.count - 1, section: 0), to: IndexPath(row: 0, section: 0))
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
        cell.isUserInteractionEnabled = true
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        tableView.reloadData()
    }

    fileprivate func stopWorkout() {
        let currentUserWorkout = userService.updateUserWorkout(runtimeWorkout.currentUserWorkout).addToDuration(workoutTimer.duration()).done(true).save()
        runtimeWorkout = RuntimeWorkout(currentUserWorkout: currentUserWorkout, lastUserWorkout: runtimeWorkout.lastUserWorkout)
        workoutTimer.stop()
        if restTimer != nil {
            restTimer.stop()
        }
        timerLabel.isHidden = true
        restLabel.isHidden = true
        progressView.setProgress(1.0, animated: false)
        startButton.isHidden = false
        startButton.setTitle("Start \(runtimeWorkout.category())", for: UIControlState())
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:greenColor]
        cancelButton.isHidden = true
    }

    func checkmarkAll() {
        for i in 0..<tasks.count {
            let _ = checkmark(i)
        }
    }

    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        settings = Settings.settings()
        debugPrint("Unwinding to main. stores \(settings.stores)")
        initStores(settings.stores)
        tableView.reloadData()
    }

    @IBAction func cancelWorkout(_ sender: AnyObject) {
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

