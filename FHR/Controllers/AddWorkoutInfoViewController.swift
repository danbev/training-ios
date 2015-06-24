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

    @IBAction func selectVideo(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.mediaTypes = [kUTTypeMovie]
        self.presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        let workout = workoutBuilder.name(workoutName.text)
            .workoutName(workoutName.text)
            .description(workoutDescription.text)
            .videoUrl(videoUrl)
            .language("en")
            .weights(false)
            .dryGround(false)
            .postRestTime(60)
            .categories(WorkoutCategory.Cardio)
            .save()
        debugPrintln("saved workout \(workout.description)")
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func cancel(sender: AnyObject) {
        debugPrintln("cancel add workout")
        navigationController?.popToRootViewControllerAnimated(true)
    }

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL!
        videoUrl = tempImage.relativePath
        if let url = videoUrl {
            debugPrintln("Saving video : :\(videoUrl)")
            UISaveVideoAtPathToSavedPhotosAlbum(videoUrl, nil, nil, nil)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
