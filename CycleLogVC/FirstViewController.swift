//
//  FirstViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 05.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var labelLogTypes: UILabel!
    @IBOutlet weak var labelSelectedType: UILabel!
    @IBOutlet weak var textFieldNote: UITextField!
    
    @IBOutlet weak var sliderMood: UISlider!
    
    
    var selectedType = "Test"
    var index = 4
    let logTypes = ["JourneyStart",
                    "JourneyEnd",
                    "DayStart",
                    "DayEnd",
                    "Checkpoint",
                    "Drink",
                    "Food",
                    "Stay",
                    "Photo"]
    
    var moodValue = 7.0
    var noteText = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    
    func initView() {
        
        labelLogTypes.text = "Available: " + logTypes.joined(separator: ", ")
        
        labelSelectedType.text = "\(logTypes[index])"
        
        textFieldNote.delegate = self
        
    }
    
    @IBAction func prevButtonClick() {
        if index >= 1 {
            index -= 1
        }
        labelSelectedType.text = "\(logTypes[index])"
    }
    
    @IBAction func nextButtonClick() {
        if index <= (logTypes.count - 2) {
            index += 1
        }
        labelSelectedType.text = "\(logTypes[index])"
    }
    
    @IBAction func addClick() {
        
        let alert = UIAlertController(title: "Alert", message: "Add Log", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                //implement ok action
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //delegate implementation, to hide keyboard of textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    
    
    
    
    
}



/*
 
 
 //function to add log
 func executeAddLog(returnMsg: inout String) {
     
     returnMsg = "" //reset
     var longitute = 0.0
     var latitude = 0.0
     
     
     //get longitute && latitude
     let tp_Loc = getLocationValues()
     if (!tp_Loc.0) {
         returnMsg = tp_Loc.1
         return
     }
     latitude = tp_Loc.2
     longitute = tp_Loc.3
     print(latitude)
     print(longitute)
     
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
     print(date)
     print(time)
     print(localeTimeZone)
     
     
 }




 func getPictureFromCamera() {
     
     //request camera access
     AVCaptureDevice.requestAccess(for: .video) { granted in
         if !granted { return }
         
         print("setup camera session")
         
         
     }
     
     
     //request photo library
     PHPhotoLibrary.requestAuthorization { status in
         guard status == .authorized else { return }
         
         print("setup photo library session")
     }
     
     
     
 }

 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     picker.dismiss(animated: true)

     guard let image = info[.editedImage] as? UIImage else {
         print("No image found")
         return
     }

     // print out the image size as a test
     print(image.size)
 }


 //returns (success, message, lat, lon)
 func getLocationValues() -> (Bool, String, Double, Double){
     
     locManager = CLLocationManager()
     var currentLocation: CLLocation! = nil

     if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() ==  .authorizedAlways {
         currentLocation = locManager!.location
     }
     else {
         locManager!.requestWhenInUseAuthorization()
         return (false, "Request Location Use", 0, 0)
     }
     
     let lat = currentLocation.coordinate.latitude
     let lon = currentLocation.coordinate.longitude
     print("longitute: \(lon)")
     print("latitude: \(lat)")
     
     return (true, "", lat, lon)
 }
 
 
 
 
 */








