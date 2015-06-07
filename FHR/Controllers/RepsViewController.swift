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

    var repsWorkout: RepsWorkout!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        repsLabel.text = repsWorkout.repititions.stringValue
    }

    public override func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, restTimer: restTimer, finishDelegate: finishDelegate)
        repsWorkout = workout as! RepsWorkout
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        BaseWorkoutController.showVideo(segue, workout: workout)
    }
}
