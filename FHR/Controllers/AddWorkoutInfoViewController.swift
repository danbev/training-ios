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

public class AddWorkoutInfoViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutDescription: UITextView!
    private var workoutService: WorkoutService!
    private var videoUrl: String?
    private var workoutType: WorkoutType!
    private var workoutBuilder: WorkoutBuilder!

    public func setWorkoutType(workoutType: WorkoutType) {
        self.workoutType = workoutType
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutDescription.delegate = self
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    public func setBuilder(workoutBuilder: WorkoutBuilder) {
        self.workoutBuilder = workoutBuilder
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func videoButtonAction(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.mediaTypes = [kUTTypeMovie]

            let frontCamera = UIImagePickerControllerCameraDevice.Front
            picker.cameraDevice = UIImagePickerController.isCameraDeviceAvailable(frontCamera) ? frontCamera: UIImagePickerControllerCameraDevice.Rear
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }

    @IBAction func nextButtonAction(sender: UIBarButtonItem) {
        switch workoutType! {
        case .Reps:
            performSegueWithIdentifier("saveRepsSegue", sender: self)
        case .Timed:
            performSegueWithIdentifier("durationSegue", sender: self)
        case .Interval:
            performSegueWithIdentifier("intervalSegue", sender: self)
        case .Prebens:
            performSegueWithIdentifier("prebensSegue", sender: self)
        }
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveRepsSegue" {
            let reps = segue.destinationViewController as! RepsInfoViewController
            reps.setWorkoutService(workoutService)
            reps.setWorkoutBuilder(workoutService.reps()
                .name(workoutName.text)
                .workoutName(workoutName.text)
                .description(workoutDescription.text)
                .videoUrl(videoUrl)
                .language("en")
                .weights(false)
                .dryGround(false)
                .postRestTime(60)
                .categories(WorkoutCategory.Cardio))
        }
    }

    @IBAction func selectVideo(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.mediaTypes = [kUTTypeMovie]
        self.presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        if let url = videoUrl {
            UISaveVideoAtPathToSavedPhotosAlbum(videoUrl, nil, nil, nil)
        }
        workoutBuilder.build()
        /*
        workoutService.saveWorkout(workoutService.reps(100)
            .name(workoutName.text)
            .workoutName(workoutName.text)
            .description(workoutDescription.text)
            .videoUrl(videoUrl)
            .language("en")
            .weights(false)
            .dryGround(false)
            .approx(300)
            .postRestTime(60)
            .categories(WorkoutCategory.Cardio))
        */
    }

    @IBAction func cancel(sender: AnyObject) {
        debugPrintln("cancel add workout")
        navigationController?.popToRootViewControllerAnimated(true)
    }

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL!
        videoUrl = tempImage.relativePath
        println("videoUrl:\(videoUrl)")
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
