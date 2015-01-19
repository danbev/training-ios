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
    @IBOutlet weak var tableView: UITableView!
    var tasks = [RepsWorkout]()
    public let tableCell = "tableCell"

    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()

    @IBAction func startWorkout(sender: UIButton) {
        let text = sender.titleLabel!.text
        if text == "Start" {
            startButton.setTitle("Paus", forState: UIControlState.Normal)
            loadTasks()
        } else {
            startButton.setTitle("Start", forState: UIControlState.Normal)
        }
    }

    public func loadTasks() {
        let worksoutTasks = fetchWorkoutTask()
        if let workouts = worksoutTasks {
            println(workouts.count)
            for task in workouts {
                println("tasks \(task.parent.name)")
                tasks.append(task)
            }
        }
        tableView.reloadData()
    }

    public func storeTasks() {
        saveWorkoutTask("Burpees", desc: "Start from standing, squat down for a pushup, touch chest on ground, and jump up", reps: 100)
        saveWorkoutTask("Chop ups", desc: "Start from lying posistion and bring your legs towards you buttocks, then stand up", reps: 100)
        saveWorkoutTask("Get ups", desc: "long description...", reps: 50)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
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
        // create a new cell or deque and reuse.
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as UITableViewCell
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.parent.name
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
        let taskViewController: TaskViewController = segue.destinationViewController as TaskViewController
        let task = tasks[tableView.indexPathForSelectedRow()!.row]
        taskViewController.workoutTask = tasks[tableView.indexPathForSelectedRow()!.row] as RepsWorkout
    }

    func saveWorkoutTask(name: String, desc: String, reps: Int) -> RepsWorkout {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!

        let workoutEntity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: managedContext)
        let workout = Workout(entity: workoutEntity!, insertIntoManagedObjectContext: managedContext)
        workout.name = name
        workout.desc = desc

        let repsWorkoutEntity = NSEntityDescription.entityForName("RepsWorkout", inManagedObjectContext: managedContext)
        let repsWorkout = RepsWorkout(entity: repsWorkoutEntity!, insertIntoManagedObjectContext: managedContext)
        repsWorkout.reps = reps
        repsWorkout.parent = workout

        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }

        return repsWorkout
    }

    func fetchWorkoutTask() -> Optional<[RepsWorkout]> {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "RepsWorkout")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [RepsWorkout]?
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return Optional.None
        }
    }

}

