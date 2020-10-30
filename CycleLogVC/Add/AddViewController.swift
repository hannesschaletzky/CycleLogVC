//
//  FirstViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 05.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit
import CoreLocation
import PhotosUI


class AddViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var selectionVC:SelectionViewController?
    
    @IBOutlet weak var tfDayEnd: UITextField!
    @IBOutlet weak var tfJourneyEnd: UITextField!
    @IBOutlet weak var sliderMood: UISlider!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var buttonJourney: UIButton!
    @IBOutlet weak var buttonType: UIButton!
    @IBOutlet weak var labelLocAccuracy: UILabel!
    
    let locAccQueue = DispatchQueue(label: "locAccuracy")
    var userLeft = false
    
    //Location
    var locManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfDayEnd.delegate = self
        tfJourneyEnd.delegate = self
        resetView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (gl_selectedJourney == "") {
            buttonJourney.setTitle("Select Journey", for: .normal)
        }
        else {
            buttonJourney.setTitle(gl_selectedJourney, for: .normal)
        }
        requestAccess()
        userLeft = false
        locAccQueue.async {
            do {
                self.displayLocAccuracy()
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        labelLocAccuracy.text = "Location Accuracy"
        userLeft = true
    }

    
    //gets also called from LogTypeVC after selection
    func handleTextFieldVisibility() {
        
        //reset
        tfDayEnd.isHidden = true
        tfJourneyEnd.isHidden = true
        
        //show according to selection
        if gl_selectedLogType == Log.Type_DayEnd {
            tfDayEnd.isHidden = false
        }
        else if gl_selectedLogType == Log.Type_JourneyEnd {
            tfJourneyEnd.isHidden = false
        }
    }
    
    func resetView() {
        
        //checkpoint by default
        buttonType.setTitle(Log.Type_Checkpoint, for: .normal)
        gl_selectedLogType = Log.Type_Checkpoint
        
        sliderMood.value = 8
        tfDayEnd.text = ""
        tfJourneyEnd.text = ""
        handleTextFieldVisibility()
        imageView1.image = nil
    }
   
    //request user authorization for all needed tasks
    func requestAccess() {
        
        //location services
        locManager = CLLocationManager()
        locManager!.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            print("Success Location Access")
        }
        
        //request camera access
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted { return }
            
            print("Success Camera Access")
        }
        
        
        //request photo library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            print("Success Photo Library Access")
        }
    }
    
    //periodically update location accuracy for the user to see
    func displayLocAccuracy() {
        
        //update location accuracy label every second until user leaves view
        var count = 0
        while !userLeft {
            
            if count == 20 {
                break
            }
            sleep(1)
            
            //get new loaction
            var loc: CLLocation! = nil
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() ==  .authorizedAlways {
                    loc = locManager!.location
            }
            else {
                return
            }
            
            //sometimes not set
            if loc == nil {
                return
            }
            
            let horValue = round(loc.horizontalAccuracy)
            let verValue = round(loc.verticalAccuracy)
            print("\(count) - horAcc: \(horValue) verAcc: \(verValue)")
            DispatchQueue.main.async {
                self.labelLocAccuracy.text = "\(count) - horAcc: \(horValue) verAcc: \(verValue)"
            }
            count = count + 1
        }
        
    }
    
    
    @IBAction func addPictureFromLibrary() {
        
        if (imageView1.image != nil) {
            //images full
            return
        }
        
        //specify whether image should be saved to library
        imageView1.tag = 0
        
        //open photo library
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: false)
        
    }
    
    
    @IBAction func addPictureFromCamera() {
        //showAlert(msg: "Add Picture!")
        
        if (imageView1.image != nil) {
            //images full
            return
        }
        
        //specify whether image should be saved to library
        imageView1.tag = 1
        
        //open camera
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.cameraCaptureMode = .photo
        vc.cameraFlashMode = .off
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: false)
    }
    
    @IBAction func undoPicture() {
        
        //cancel if no image exists
        if (imageView1.image == nil) {
            return
        }
        
        let refreshAlert = UIAlertController(title: "Undo?", message: "Picture will be discarded", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.imageView1.image = nil
          }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    //touch up inside
    @IBAction func moodSliderChanged_1(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
    }
    
    //touch up outside
    @IBAction func moodSliderChanged_2(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
    }
    
    
    
    @IBAction func addClick() {
        
        //check general validity
        if (locManager!.location == nil) {
            showAlert(msg: "could not get location")
            return
        }
        
        if (gl_selectedJourney == "") {
            showAlert(msg: "Please select a journey")
            return
        }
        
        if (gl_selectedLogType == "") {
            showAlert(msg: "Please select a logType")
            return
        }
        
        //fetch & parse values
        var kmCount = 0
        let tpLocation = getLocationValues()
        let tpDateTime = getDateTimeZone()
        let moodValue = Int(sliderMood.value)
        var img1Key = ""
        var imgOrientation = ""
        let note = "" //DETERMINE
        let isSynced = false
        var isOfflineLog = false
        var finalValues = ""
        let other = ""
        
        //check km count
        if gl_selectedLogType == Log.Type_DayEnd {
            if let num = tfDayEnd.text?.integerValue {
                kmCount = num
            }
            else {
                showAlert(msg: "Please provide a valid km count")
                return
            }
        }
        
        //check final values for journey end
        if gl_selectedLogType == Log.Type_JourneyEnd {
            if tfJourneyEnd.text == "" {
                showAlert(msg: "Please provide valid journey end data")
                return
            }
            else {
                //km;time;avg;max;cal
                //377;15:19;24,63;52,35;6.700
                finalValues = tfJourneyEnd.text!
            }
        }
        
        //determine offlineLog
        print("currentReachabilityStatus: \(currentReachabilityStatus)")
        if currentReachabilityStatus == .notReachable {
           isOfflineLog = true
        }
        
        
        //Determine image
        if (imageView1.image != nil) {
            
            //get image orietation
            imgOrientation = getImageOrientationDefinitionFor(image: imageView1.image!)
            
            //save image to library when tag == 1 -> image from camera
            if (imageView1.tag == 1) {
                UIImageWriteToSavedPhotosAlbum(imageView1.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            
            //save image to storage
            img1Key = UUID().uuidString
            let tp_saveImg = saveImage(image: imageView1.image!, forKey: img1Key)
            if (!tp_saveImg.0) {
                showAlert(msg: "Error saving image to storage: \(tp_saveImg.1)")
                return
            }
        }
        
        sleep(1)
        //save log to CoraData
        let log = Log(journey: gl_selectedJourney, tpDateTime: tpDateTime, type: gl_selectedLogType, mood: moodValue, kmCount: kmCount, tpLocation: tpLocation, image1: img1Key, imgOrientation: imgOrientation, note: note, isSynced: isSynced, isOfflineLog: isOfflineLog, finalValues: finalValues, other: other)
        let tp_saveLog = saveLog(logToSave: log)
        
        if (!tp_saveLog.0) {
            showAlert(msg: "saveLog failed: \(tp_saveLog.1)")
            return
        }
        
        resetView()
        showAlert(msg: "Saved Log!")
    }
    
    
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Cycle Log", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                //implement ok action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
                               //lat    lon     horAcc   verAcc
    func getLocationValues() -> (Double, Double, Double, Double) {
        
        var currentLocation: CLLocation! = nil

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            currentLocation = locManager!.location
        }
        else {
            locManager!.requestWhenInUseAuthorization()
        }
        
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        let horAcc = round(currentLocation.horizontalAccuracy)
        let verAcc = round(currentLocation.verticalAccuracy)
        //print("longitute: \(lon)")
        //print("latitude: \(lat)")
        
        return (lat, lon, horAcc, verAcc)
    }
    
    func getDateTimeZone() -> (String, String, String) {
        
        //get current timestamp
        var date = "";
        var time = "";
        var localeTimeZone = ""
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        date = formatter.string(from: now)
        formatter.dateFormat = "HH:mm:ss"
        time = formatter.string(from: now)
        if let ltz = TimeZone.current.abbreviation() {
            localeTimeZone = ltz
        }
        //print(date)
        //print(time)
        //print(localeTimeZone)
        
        return (date, time, localeTimeZone)
        
    }
    
    
    //delegate picture picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            showAlert(msg: "No image found")
            return
        }
        
        imageView1.image = image
    }
    
    
    
    
    //delegate save picture to library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            showAlert(msg: "error saving image")
        } else {
            //no error
            print("image saved!")
        }
        
    }
    
    //delegate to hide keyboard of textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showJourney") {
            let journeyVC = (segue.destination as! JourneyViewController)
            journeyVC.addVC = self
        }
        else if (segue.identifier == "selectType") {
            let selectionVC = (segue.destination as! SelectionViewController)
            self.selectionVC = selectionVC
            selectionVC.addVC = self
            selectionVC.caller = TypeSelectionCaller.addLog
        }
        
        
    }
    
}











