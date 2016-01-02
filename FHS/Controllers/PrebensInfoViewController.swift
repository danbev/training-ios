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
    @IBOutlet weak var picker: UIPickerView!
    private var workoutService: WorkoutService!
    private var builder: PrebensBuilder!
    private var workouts = [String]()
    private var selectedWorkouts = [WorkoutContainer]()
    public let tableCell = "tableCell"

    public override func viewDidLoad() {
        super.viewDidLoad()
        workouts = workoutService.fetchRepsWorkoutsDestinct()!
        picker.selectRow(workouts.count / 2, inComponent: 0, animated: false)
        tableView.allowsMultipleSelectionDuringEditing = false;
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "infoSegue" {
            let workoutName = sender as! String
            debugPrint(workoutName)
            let workout = workoutService.fetchWorkoutProtocol(workoutName)!
            let infoController = segue.destinationViewController as! InfoViewController
            infoController.initWith(workout)
        } else {
            let controller = segue.destinationViewController as! AddWorkoutInfoViewController
            let prebensBuilder = workoutService.prebens()
            for r in selectedWorkouts {
                prebensBuilder.workItemFrom(r.workoutName, reps: r.reps)
            }
            controller.setBuilder(prebensBuilder)
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workouts.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return workouts[row]
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let workoutName = workouts[row]
        let alert = UIAlertController(title: "Reps", message: "Enter number of reps", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "10"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { [unowned self] (action) -> Void in
            let textField = alert.textFields![0] 
            self.selectedWorkouts.append(WorkoutContainer(workoutName: workoutName, reps: Int(textField.text!)!))
            self.tableView.reloadData()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let titleData = workouts[row]
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.Center
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
        let workoutContainer = selectedWorkouts[indexPath.row]
        performSegueWithIdentifier("infoSegue", sender: workoutContainer.workoutName)
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWorkouts.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell, forIndexPath: indexPath)
        let workoutContainer = selectedWorkouts[indexPath.row]
        cell.textLabel!.text = workoutContainer.workoutName
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = String(workoutContainer.reps)
        return cell;
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            selectedWorkouts.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }

    private struct WorkoutContainer {
        let workoutName: String
        let reps: Int
    }
}

