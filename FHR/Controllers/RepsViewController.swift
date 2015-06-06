//
//  RepsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

/**
Controlls a Reps based workout

*/
public class RepsViewController: BaseWorkoutController {

    var currentUserWorkout : UserWorkout!
    var repsWorkout: RepsWorkout!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        repsWorkout = workout as! RepsWorkout
        repsLabel.text = repsWorkout.repititions.stringValue
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        BaseWorkoutController.showVideo(segue, workout: workout)
    }
}
