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
    
    @IBOutlet weak var tableView: UITableView!
    //public var tasks = Array<WorkoutTask>()
    public var tasks = [NSManagedObject]()
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        saveWorkoutTask(WorkoutTask(name: "Burpees", reps: 100, desc: "Start from standing, squat down for a pushup, touch chest on ground, and jump up"))
        saveWorkoutTask(WorkoutTask(name: "Chop ups", reps: 100, desc: "Start from lying posistion and bring your legs towards you buttocks, then stand up"))
        saveWorkoutTask(WorkoutTask(name: "Get ups", reps: 50, desc: "long description..."))
        //tasks.append(WorkoutTask(name: "Burpees", reps: 100, desc: "Start from standing, squat down for a pushup, touch chest on ground, and jump up"))
        //tasks.append(WorkoutTask(name: "Chop ups", reps: 100, desc: "Start from lying posistion and bring your legs towards you buttocks, then stand up"))
        //tasks.append(WorkoutTask(name: "Get ups", reps: 50, desc: "long description..."))
        println(managedObjectContext!)
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
        //cell.textLabel!.text = tasks[indexPath.row].name
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.valueForKey("name") as String!
        return cell;
    }

    /**
    Handle taps of items in the workout task list.

    :param: tableView the UITableView which was tapped
    :param: indexPath the NSIndexPath identifying the cell to being tapped
    */
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("selected:\(tasks[indexPath.row)]")
    }

    /**
    Prepares the transistion from the main view to the workout task details view.

    :param: segue the UIStoryboardSeque that was called
    */
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let taskViewController: TaskViewController = segue.destinationViewController as TaskViewController
        let task = tasks[tableView.indexPathForSelectedRow()!.row]
        taskViewController.workoutTask = asWorkoutTask(tasks[tableView.indexPathForSelectedRow()!.row])
    }

    func asWorkoutTask(data: NSManagedObject) -> WorkoutTask {
        return WorkoutTask(name: data.valueForKey("name") as String, reps: data.valueForKey("reps") as Int, desc: data.valueForKey("desc") as String)
    }

    func saveWorkoutTask(task: WorkoutTask) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("WorkoutTask", inManagedObjectContext: managedContext)
        let workoutTask = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        workoutTask.setValue(task.name, forKey: "name")
        workoutTask.setValue(task.reps, forKey: "reps")
        workoutTask.setValue(task.desc, forKey: "desc")
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }

        tasks.append(workoutTask)
    }

}

