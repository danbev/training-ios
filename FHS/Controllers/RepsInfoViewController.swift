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

open class RepsInfoViewController: UIViewController {

    @IBOutlet weak var repsLabel: UILabel!
    fileprivate var workoutService: WorkoutService!
    fileprivate var workoutType: WorkoutType!
    fileprivate var builder: RepsBuilder!
    @IBOutlet weak var approxTimeStepper: UIStepper!
    @IBOutlet weak var repsStepper: UIStepper!
    @IBOutlet weak var approxTimeLabel: UILabel!

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
        let reps = Int(repsLabel.text!)!
        controller.setBuilder(workoutService.reps(reps).approx(NSNumber(value: Int(approxTimeLabel.text!)!)))
    }

    open func setWorkoutBuilder(_ builder: RepsBuilder) {
        self.builder = builder
    }

    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func stepper(_ sender: UIStepper) {
        repsLabel.text = Int(sender.value).description
    }

    @IBAction func approxStepper(_ sender: UIStepper) {
        approxTimeLabel.text = Int(sender.value).description
    }
}
