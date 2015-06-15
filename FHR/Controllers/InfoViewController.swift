//
//  InfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 04/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class InfoViewController: UIViewController {

    @IBOutlet weak var workoutNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    public var workout : Workout!

    public override func viewDidLoad() {
        super.viewDidLoad()
        setTextLabels(workout)
    }

    public func initWith(workout: Workout) {
        self.workout = workout
    }

    func setTextLabels(workout: Workout) {
        workoutNameLabel.text = workout.workoutName
        descriptionLabel.text = workout.workoutDescription
    }

    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        BaseWorkoutController.showVideo(segue, workout: workout)
    }

}
