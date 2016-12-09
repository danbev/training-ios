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
open class RepsViewController: BaseWorkoutController, UITableViewDelegate, UITableViewDataSource {

    let tableCell = "timeCell"
    var repsWorkout: RepsWorkoutProtocol!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var tableView: UITableView!

    open override func viewDidLoad() {
        super.viewDidLoad()
        repsLabel.text = repsWorkout.repititions().stringValue
    }

    open override func initWith(_ workout: WorkoutProtocol, userWorkouts: WorkoutInfo?, restTimer: CountDownTimer?, finishDelegate: @escaping FinishDelegate) {
        super.initWith(workout, userWorkouts: userWorkouts, restTimer: restTimer, finishDelegate: finishDelegate)
        repsWorkout = workout as! RepsWorkoutProtocol
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCell, for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel!.text = "Rest time"
            cell.textLabel!.textAlignment = NSTextAlignment.center
            cell.textLabel!.textColor = UIColor.white
        } else {
            cell.textLabel!.text = "00:00:00"
            cell.textLabel!.textAlignment = NSTextAlignment.center
            cell.textLabel!.textColor = UIColor.white
        }
        return cell;
    }

}
