//
//  AddWorkoutViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/06/15.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

/**
* Main view controller for workout tasks.
*/
open class AddWorkoutViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    var workoutTypes = [WorkoutType.Reps, WorkoutType.Timed, WorkoutType.Interval, WorkoutType.Prebens]
    var selectedType: WorkoutType = WorkoutType.Reps
    var workoutService: WorkoutService!
    var userService: UserService!

    open override func viewDidLoad() {
        super.viewDidLoad()
        let coreDataStack = CoreDataStack.storesFromBundle(["UserWorkouts"], modelName: "FHS")
        workoutService = WorkoutService(coreDataStack: coreDataStack, userService: userService)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    open func setUserService(_ userService: UserService) {
        self.userService = userService
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workoutTypes.count
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return workoutTypes[row].rawValue
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _ = workoutTypes[row]
    }

    @IBAction func next(_ sender: AnyObject) {
        selectedType = workoutTypes[pickerView.selectedRow(inComponent: 0)]
        switch selectedType {
        case .Reps:
            performSegue(withIdentifier: "repsDetailsSegue", sender: self)
        case .Timed:
            performSegue(withIdentifier: "durationDetailSegue", sender: self)
        case .Interval:
            performSegue(withIdentifier: "intervalDetailsSegue", sender: self)
        case .Prebens:
            performSegue(withIdentifier: "prebensDetailsSegue", sender: self)
        }
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch selectedType {
        case .Reps:
            let controller = segue.destination as! RepsInfoViewController
            controller.setWorkoutService(workoutService)
        case .Timed:
            let controller = segue.destination as! DurationInfoViewController
            controller.setWorkoutService(workoutService)
        case .Interval:
            let controller = segue.destination as! IntervalInfoViewController
            controller.setWorkoutService(workoutService)
        case .Prebens:
            let controller = segue.destination as! PrebensInfoViewController
            controller.setWorkoutService(workoutService)
        }
    }

    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = workoutTypes[row].rawValue
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
}

