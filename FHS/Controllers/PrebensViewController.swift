// //  PrebensViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 27/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//
import Foundation
import UIKit
import Foundation

open class PrebensViewController: BaseWorkoutController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prebensLabel: UILabel!
    var prebensWorkout : PrebensWorkoutProtocol!
    var tasks = [RepsWorkoutProtocol]()
    open let tableCell = "tableCell"

    open override func viewDidLoad() {
        super.viewDidLoad()
        prebensWorkout = workout as! PrebensWorkoutProtocol
        for w in prebensWorkout.workouts() {
            tasks.append(w)
        }
        tableView.reloadData()
    }

    open override func initWith(_ workout: WorkoutProtocol, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: @escaping FinishDelegate) {
        super.initWith(workout, userWorkouts: userWorkouts, restTimer: restTimer, finishDelegate: finishDelegate)
        prebensWorkout = workout as! PrebensWorkoutProtocol
    }

    /**
    Handle taps of items in the workout task list.

    - parameter tableView: the UITableView which was tapped
    - parameter indexPath: the NSIndexPath identifying the cell to being tapped
    */
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView row selected = \(indexPath)")
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let infoController = segue.destination as! InfoViewController
            if let indexPath = sender as? IndexPath {
                infoController.initWith(tasks[indexPath.row])
            } else {
                infoController.initWith(prebensWorkout)
            }
        }
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "infoSegue", sender: indexPath)
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
        cell.textLabel!.textColor = UIColor.white
        cell.detailTextLabel?.text = task.repititions().stringValue
        return cell;
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
