//
//  RepsInfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class PrebensInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private var workoutService: WorkoutService!
    private var builder: PrebensBuilder!
    private var workouts = [RepsWorkout]()
    private var selectedWorkouts = [RepsWorkout]()
    public let tableCell = "tableCell"

    public override func viewDidLoad() {
        super.viewDidLoad()
        workouts = workoutService.fetchRepsWorkouts()!
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "infoSegue" {
            debugPrintln(sender)
            let workout = sender as! RepsWorkout
            let infoController = segue.destinationViewController as! InfoViewController
            infoController.initWith(workout)
        } else {
            let controller = segue.destinationViewController as! AddWorkoutInfoViewController
            controller.setBuilder(workoutService.prebens().workouts(selectedWorkouts))
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workouts.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return workouts[row].workoutName
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        println("picked row: \(row)")
        let workout = workouts[row]
        selectedWorkouts.append(workout)
        tableView.reloadData()
    }

    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let workoutName = workouts[row].workoutName
        let attributedString = NSAttributedString(string: workoutName, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let titleData = workouts[row].workoutName
        let pickerLabel = UILabel()
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let workout = selectedWorkouts[indexPath.row]
        performSegueWithIdentifier("infoSegue", sender: workout)
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWorkouts.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        let task = selectedWorkouts[indexPath.row]
        cell.textLabel!.text = task.workoutName
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = task.repititions.stringValue
        return cell;
    }
}
