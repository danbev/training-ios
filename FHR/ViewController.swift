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

    private var startTime: NSTimeInterval = NSTimeInterval()

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutService = WorkoutService(context: coreDataStack.context)
        workoutService.loadDataIfNeeded()
    }

    public func updateTime(timer: NSTimer) {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime = 2700-(currentTime - startTime)
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        timerLabel.hidden = false
        timerLabel.text = "\(strMinutes):\(strSeconds)"
        counter++;
    }

    public func callback() {
        counter++
    }

    var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 1000.0
            let animated = counter != 0
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

    @IBAction func startWorkout(sender: UIButton) {
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateTime:"), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        startButton.hidden = true
        loadTask()
    }

    @IBAction func addWorkout(sender: AnyObject) {
        println("add a new workout...")
    }
    
    public func loadTask() {
        let workout = workoutService.fetchWarmup()!
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
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as UITableViewCell
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.name()
        return cell;
    }

    /**
    Handle taps of items in the workout task list.

    :param: tableView the UITableView which was tapped
    :param: indexPath the NSIndexPath identifying the cell to being tapped
    */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //println("selected:\(tasks[indexPath.row)]")
    }

    /**
    Prepares the transistion from the main view to the workout task details view.

    :param: segue the UIStoryboardSeque that was called
    */
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let task = tasks[tableView.indexPathForSelectedRow()!.row]
        switch task.type() {
        case .Warmup:
            let taskViewController = segue.destinationViewController as RepsViewController
            let workout = tasks[tableView.indexPathForSelectedRow()!.row] as Workout
            taskViewController.workout = workout.reps
            taskViewController.didFinish = { controller in
                println("Closed reps: \(controller.workout.reps)")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        case .Reps:
            println("reps task...")
        case .Timed:
            println("timed task...")
        case .Interval:
            println("interval task...")
        }
    }

}

