//
//  AddWorkoutInfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import MobileCoreServices

open class GeneralDetails2: UIViewController {

    fileprivate var workoutBuilder: WorkoutBuilder!

    @IBOutlet weak var weightsSwitch: UISwitch!
    @IBOutlet weak var dryGroundSwitch: UISwitch!
    @IBOutlet weak var warmupSwitch: UISwitch!
    @IBOutlet weak var upperbodySwitch: UISwitch!
    @IBOutlet weak var lowerbodySwitch: UISwitch!
    @IBOutlet weak var cardioSwitch: UISwitch!
    @IBOutlet weak var postRestLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    fileprivate var categories = Set<WorkoutCategory>()
    fileprivate let onTintColor = UIColor(red: 0.0/255, green: 200.0/255, blue: 0.0/255, alpha: 1.0)

    open override func viewDidLoad() {
        super.viewDidLoad()
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        weightsSwitch.setOn(false, animated: false)
        weightsSwitch.onTintColor = onTintColor
        dryGroundSwitch.setOn(false, animated: false)
        dryGroundSwitch.onTintColor = onTintColor
        warmupSwitch.setOn(false, animated: false)
        warmupSwitch.onTintColor = onTintColor
        upperbodySwitch.setOn(false, animated: false)
        upperbodySwitch.onTintColor = onTintColor
        lowerbodySwitch.setOn(false, animated: false)
        lowerbodySwitch.onTintColor = onTintColor
        cardioSwitch.setOn(false, animated: false)
        cardioSwitch.onTintColor = onTintColor
        stepper.value = 1

    }

    func gatherCategories() -> [WorkoutCategory] {
        var categories = [WorkoutCategory]()
        if warmupSwitch.isOn {
            categories.append(WorkoutCategory.Warmup)
        }
        if upperbodySwitch.isOn {
            categories.append(WorkoutCategory.UpperBody)
        }
        if lowerbodySwitch.isOn {
            categories.append(WorkoutCategory.LowerBody)
        }
        if cardioSwitch.isOn {
            categories.append(WorkoutCategory.Cardio)
        }
        return categories
    }

    open func setBuilder(_ workoutBuilder: WorkoutBuilder) {
        self.workoutBuilder = workoutBuilder
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMain" {
            let workout = workoutBuilder.language("en")
                .weights(weightsSwitch.isOn)
                .dryGround(dryGroundSwitch.isOn)
                .postRestTime(NSNumber(value: Int(postRestLabel.text!)!))
                .categories(gatherCategories())
                .saveWorkout()
            debugPrint("saved workout \(workout)")
            Settings.enableUserWorkoutsStore()
        }
    }

    @IBAction func save(_ sender: AnyObject) {
        /*
        let workout = workoutBuilder.language("en")
            .weights(weightsSwitch.on)
            .dryGround(dryGroundSwitch.on)
            .postRestTime(postRestLabel.text!.toInt()!)
            .categories(gatherCategories())
            .saveWorkout()
        debugPrintln("saved workout \(workout)")
        Settings.enableUserWorkoutsStore()
        navigationController?.popToRootViewControllerAnimated(true)
        */
    }

    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func stepper(_ sender: UIStepper) {
        postRestLabel.text = Int(sender.value).description
    }
}
