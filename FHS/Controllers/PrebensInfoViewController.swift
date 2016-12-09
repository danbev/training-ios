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

open class PrebensInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var picker: UIPickerView!
    fileprivate var workoutService: WorkoutService!
    fileprivate var builder: PrebensBuilder!
    fileprivate var workouts = [String]()
    fileprivate var selectedWorkouts = [WorkoutContainer]()
    open let tableCell = "tableCell"

    open override func viewDidLoad() {
        super.viewDidLoad()
        workouts = workoutService.fetchRepsWorkoutsDestinct()!
        picker.selectRow(workouts.count / 2, inComponent: 0, animated: false)
        tableView.allowsMultipleSelectionDuringEditing = false;
    }

    open func setWorkoutService(_ workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(_ sender: AnyObject) {
        performSegue(withIdentifier: "generalWorkoutDetails", sender: self)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let workoutName = sender as! String
            debugPrint(workoutName)
            let workout = workoutService.fetchWorkoutProtocol(workoutName)!
            let infoController = segue.destination as! InfoViewController
            infoController.initWith(workout)
        } else {
            let controller = segue.destination as! AddWorkoutInfoViewController
            let prebensBuilder = workoutService.prebens()
            for r in selectedWorkouts {
                let _ = prebensBuilder.workItemFrom(r.workoutName, reps: r.reps)
            }
            controller.setBuilder(prebensBuilder)
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workouts.count
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return workouts[row]
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let workoutName = workouts[row]
        let alert = UIAlertController(title: "Reps", message: "Enter number of reps", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = "10"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self] (action) -> Void in
            let textField = alert.textFields![0] 
            self.selectedWorkouts.append(WorkoutContainer(workoutName: workoutName, reps: Int(textField.text!)!))
            self.tableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleData = workouts[row]
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.center
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let workoutContainer = selectedWorkouts[indexPath.row]
        performSegue(withIdentifier: "infoSegue", sender: workoutContainer.workoutName)
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWorkouts.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCell, for: indexPath)
        let workoutContainer = selectedWorkouts[indexPath.row]
        cell.textLabel!.text = workoutContainer.workoutName
        cell.textLabel!.textColor = UIColor.white
        cell.detailTextLabel?.text = String(workoutContainer.reps)
        return cell;
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            selectedWorkouts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }

    fileprivate struct WorkoutContainer {
        let workoutName: String
        let reps: Int
    }
}

