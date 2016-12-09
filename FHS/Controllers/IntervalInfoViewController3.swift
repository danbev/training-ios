//
//  IntervalInfoViewController3.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

open class IntervalInfoViewController3: UIViewController {

    fileprivate var builder: IntervalBuilder!

    @IBOutlet weak var intervalsLabel: UILabel!

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open func setBuilder(_ builder: IntervalBuilder) {
        self.builder = builder
    }

    @IBAction func next(_ sender: AnyObject) {
        performSegue(withIdentifier: "generalWorkoutDetails", sender: self)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! AddWorkoutInfoViewController
        let _ = builder.intervals(Int(intervalsLabel.text!)!)
        controller.setBuilder(builder)
    }

    @IBAction func stepper(_ sender: UIStepper) {
        intervalsLabel.text = Int(sender.value).description
    }

    open func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBAction func cancel(_ sender: AnyObject) {
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func back(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }

}
