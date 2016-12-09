//
//  IntervalInfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

open class IntervalInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    fileprivate var workoutService: WorkoutService!
    fileprivate var workoutType: WorkoutType!

    @IBOutlet weak var workoutPicker: UIPickerView!
    @IBOutlet weak var workDurationLabel: UILabel!
    fileprivate var workouts: [String]!

    open override func viewDidLoad() {
        super.viewDidLoad()
        workoutPicker.selectRow(workouts.count/2, inComponent: 0, animated: false)
    }

    open func setWorkoutService(_ workoutService: WorkoutService) {
        self.workoutService = workoutService
        workouts = workoutService.fetchDurationWorkoutsDestinct()
    }

    @IBAction func next(_ sender: AnyObject) {
        performSegue(withIdentifier: "intervalDetails2Segue", sender: self)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! IntervalInfoViewController2
        controller.setWorkoutService(workoutService)
        let workoutName = workouts[workoutPicker.selectedRow(inComponent: 0)]
        let workout = workoutService.fetchWorkoutProtocol(workoutName) as! DurationWorkoutProtocol
        let builder = workoutService.interval(workout, duration: Int(workDurationLabel.text!)!)
        controller.setBuilder(builder)
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workouts.count
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return workouts[row]
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleData = workouts[row]
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.center
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func workDurationStepper(_ sender: UIStepper) {
        workDurationLabel.text = Int(sender.value).description
    }

}
