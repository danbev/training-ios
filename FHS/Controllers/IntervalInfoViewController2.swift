//
//  IntervalInfoViewController2.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

open class IntervalInfoViewController2: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    fileprivate var workoutService: WorkoutService!
    fileprivate var builder: IntervalBuilder!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var restPicker: UIPickerView!
    @IBOutlet weak var restDurationLabel: UILabel!
    fileprivate var restWorkouts: [String]!


    open override func viewDidLoad() {
        super.viewDidLoad()
        restPicker.selectRow(restWorkouts.count/2, inComponent: 0, animated: false)
    }

    open func setBuilder(_ builder: IntervalBuilder) {
        self.builder = builder
        let workoutName = builder.workoutName()
        restWorkouts = restWorkouts.filter { $0 != workoutName }
    }

    open func setWorkoutService(_ workoutService: WorkoutService) {
        self.workoutService = workoutService
        restWorkouts = workoutService.fetchDurationWorkoutsDestinct()
    }

    @IBAction func next(_ sender: AnyObject) {
        performSegue(withIdentifier: "intervalDetails3Segue", sender: self)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! IntervalInfoViewController3
        let restWorkoutName = restWorkouts[restPicker.selectedRow(inComponent: 0)]
        let rest = workoutService.fetchWorkoutProtocol(restWorkoutName) as! DurationWorkoutProtocol
        let _ = builder.rest(rest, duration: Int(restDurationLabel.text!)!)
        controller.setBuilder(builder)
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return restWorkouts.count
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return restWorkouts[row]
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let workoutName = restWorkouts[row]
        let attributedString = NSAttributedString(string: workoutName, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }

    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleData = restWorkouts[row]
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.center
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func restDurationStepper(_ sender: UIStepper) {
        restDurationLabel.text = Int(sender.value).description
    }
    
}
