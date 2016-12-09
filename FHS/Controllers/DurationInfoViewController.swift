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

open class DurationInfoViewController: UIViewController, UITextFieldDelegate {

    fileprivate var workoutService: WorkoutService!
    fileprivate var workoutType: WorkoutType!
    fileprivate var builder: DurationBuilder!
    @IBOutlet weak var durationLabel: UILabel!

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open func setWorkoutService(_ workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(_ sender: AnyObject) {
        performSegue(withIdentifier: "generalWorkoutDetails", sender: self)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! AddWorkoutInfoViewController
        controller.setBuilder(workoutService.duration(NSNumber(value: Int(durationLabel.text!)!)))
    }

    open func setWorkoutBuilder(_ builder: DurationBuilder) {
        self.builder = builder
    }

    open func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func stepper(_ sender: UIStepper) {
        durationLabel.text = Int(sender.value).description
    }
}
