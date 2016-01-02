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

public class RepsInfoViewController: UIViewController {

    @IBOutlet weak var repsLabel: UILabel!
    private var workoutService: WorkoutService!
    private var workoutType: WorkoutType!
    private var builder: RepsBuilder!
    @IBOutlet weak var approxTimeStepper: UIStepper!
    @IBOutlet weak var repsStepper: UIStepper!
    @IBOutlet weak var approxTimeLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AddWorkoutInfoViewController
        controller.setBuilder(workoutService.reps(Int(repsLabel.text!)!).approx(Int(approxTimeLabel.text!)!))
    }

    public func setWorkoutBuilder(builder: RepsBuilder) {
        self.builder = builder
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func stepper(sender: UIStepper) {
        repsLabel.text = Int(sender.value).description
    }

    @IBAction func approxStepper(sender: UIStepper) {
        approxTimeLabel.text = Int(sender.value).description
    }
}
