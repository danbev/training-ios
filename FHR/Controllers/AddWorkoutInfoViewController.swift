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

public class AddWorkoutInfoViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutDescription: UITextView!
    private lazy var coreDataStack = CoreDataStack()
    private var workoutService: WorkoutService!

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutDescription.delegate = self
        workoutService = WorkoutService(context: coreDataStack.context)
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func videoButtonAction(sender: AnyObject) {
        debugPrintln("take/pick a video")
        var picker = UIImagePickerController()

        let sourceType = UIImagePickerControllerSourceType.Camera
        if (UIImagePickerController.isSourceTypeAvailable(sourceType)) {
            // we can use the camera
            picker.sourceType = UIImagePickerControllerSourceType.Camera

            let frontCamera = UIImagePickerControllerCameraDevice.Front
            let rearCamera = UIImagePickerControllerCameraDevice.Rear
            //use the front-facing camera if available
            if (UIImagePickerController.isCameraDeviceAvailable(frontCamera)) {
                picker.cameraDevice = frontCamera
            }
            else {
                picker.cameraDevice = rearCamera
            }
            // make this object be the delegate for the picker
            picker.delegate = self

            self.presentViewController(picker, animated: true,
                completion: nil)
        }
    }

    @IBAction func selectVideo(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        debugPrintln("Workout name: \(workoutName.text)")
        debugPrintln("Workout description: \(workoutDescription.text)")
        debugPrintln("Workout video: \(imageView.description)")
        let repsworkout = workoutService.addRepsWorkout(workoutName.text, desc: workoutDescription.text, reps: 100, videoUrl: "videoUrlHere", categories: WorkoutCategory.Cardio)
        debugPrintln("Saved \(repsworkout)")
    }

    @IBAction func cancel(sender: AnyObject) {
        debugPrintln("cancel add workout")
        dismissViewControllerAnimated(true, completion: {})
    }

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
