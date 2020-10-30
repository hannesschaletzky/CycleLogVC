//
//  ProfileViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 06.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    //logs upload
    var logTotal = 0
    var logPackInit = 0
    var logPackSuccess = 0
    var logPackSize = 25 //upload 25 logs per package
    var logSuccess = 0
    var logError = 0
    var logDone = false
    var logsToUpload:[Log] = []
    var logIndex = 0
    
    //pics upload
    var imgTotal = 0
    var imgPackInit = 0
    var imgPackSuccess = 0
    var imgPackSize = 5 //upload 5 pictures per package
    var imgSuccess = 0
    var imgError = 0
    var imgDone = false
    var alreadyUploadedPictures = ""
    var logsWithImages:[Log] = []
    var imgIndex = 0
    
    let uploadQueue = DispatchQueue(label: "uploadQueue")
    let urlSession = URLSession.shared
    
    @IBOutlet weak var buttonJourney: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (gl_selectedJourney == "") {
            buttonJourney.setTitle("Select Journey", for: .normal)
        }
        else {
            buttonJourney.setTitle(gl_selectedJourney, for: .normal)
        }
    }
    
    
    
    
    func reportProgressLogs(isSuccess :Bool) {
       
        if isSuccess {
            logSuccess = logSuccess + 1
            logPackSuccess = logPackSuccess + 1
            print("Success Log Upload \(logSuccess)")
        }
        else {
            logError = logError + 1
            print("--- Error Log Upload ---")
        }
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Logs: S:\(self.logSuccess) - E:\(self.logError) - T:\(self.logTotal)"
        }
        
        if logSuccess == logTotal {
            showAlert(msg: "Successfully uploaded \(logTotal) Logs")
            logDone = true
        }
        else if logPackSuccess == logPackSize && !logDone {
            print("\nTrigger new package of \(logPackSize)")
            handleLogUpload()
        }
        
    }
    
    func reportProgressPics(isSuccess :Bool) {
        if isSuccess {
            imgSuccess = imgSuccess + 1
            imgPackSuccess = imgPackSuccess + 1
            print("Success Image Upload \(imgSuccess)")
        }
        else {
            imgError = imgError + 1
            print("--- Error Image Upload ---")
        }
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Images: S:\(self.imgSuccess) - E:\(self.imgError) - T:\(self.imgTotal)"
        }
        
        if imgSuccess == imgTotal {
            showAlert(msg: "Successfully uploaded \(imgTotal) Images")
            imgDone = true
        }
        else if imgPackSuccess == imgPackSize && !imgDone {
            print("\nTrigger new package of \(imgPackSize)\n")
            handleImgUpload()
        }
        
    }
    
    
    
    @IBAction func addAllLogs(_ sender: Any) {
        
        //check if journey was selected
        if gl_selectedJourney == "" {
            showAlert(msg: "Please select a journey")
            return
        }
        
        //get all Logs
        let tp_logs = getLogs()
        if (!tp_logs.0) {
            showAlert(msg: "Error getting Logs: \(tp_logs.1)")
            return
        }
        let logs = tp_logs.2
        
        //only add logs of selected journey and isSynced = false
        logsToUpload.removeAll()
        for log in logs {
            if !log.isSynced && log.journey == gl_selectedJourney {
                logsToUpload.append(log)
            }
        }
        if logsToUpload.count == 0 {
            showAlert(msg: "No unsynced Logs found")
            return
        }
        
        //reset control variables
        let logCount = logsToUpload.count
        print("Uploading \(logCount) Log/s of: \(gl_selectedJourney)")
        statusLabel.text = "Init Log Upload of \(logCount)"
        logDone = false
        logSuccess = 0
        logError = 0
        logTotal = logCount
        logIndex = 0
        handleLogUpload()
        
    }
    
    
    
    func handleLogUpload() {
        
        logPackInit = 0
        logPackSuccess = 0
        
        while true {
            
            if logIndex == logsToUpload.count {
                return //finished
            }
            
            //upload only a certain amount per request
            if logPackInit == logPackSize {
                return
            }
            
            let log = logsToUpload[logIndex]
            print("\(logIndex) - \(logPackInit) - \(log.date),\(log.time)")
            uploadLog(log: log)
            logPackInit = logPackInit + 1
            logIndex = logIndex + 1
        }
    }
    
    
    func uploadLog(log:Log) {
        
        var logWasSaved = false
        log.isSynced = true
        let tpEditLog = editLog(newLog: log)
        if (tpEditLog.0) {
            logWasSaved = true
        }
        
        var urlString = "https://cyclocrossingborders.de/addLog.php?journey=\(log.journey)&date=\(log.date)&time=\(log.time)&timeZone=\(log.timeZone)&type=\(log.type)&mood=\(log.mood)&kmCount=\(log.kmCount)&longitute=\(log.lon)&latitude=\(log.lat)&horAcc=\(log.horAcc)&verAcc=\(log.verAcc)&image1=\(log.image1!)&imgOrientation=\(log.imgOrientation!)&note=\(log.note)&isSynced=\(log.isSynced)&isOfflineLog=\(log.isOfflineLog)&finalValues=\(log.finalValues)&other=\(log.other)"
        urlString = urlString.replacingOccurrences(of: " ", with: "%20")
        
        let url = URL(string: urlString)
        
        if (url != nil) {
         
            uploadQueue.async {
                do {
                    let task = self.urlSession.dataTask(with: url!) { (data, response, error) in

                        // Fehlerbehandlung für den Fall, das ein Fehler aufgetreten ist oder data nicht gesetzt ist
                        guard let data = data, error == nil else {
                            //debugPrint("Fehler beim Laden von \(url)", String(describing: error))
                            log.isSynced = false
                            _ = editLog(newLog: log)
                            DispatchQueue.main.async {
                                self.reportProgressLogs(isSuccess: false)
                            }
                            return
                        }

                        // Geladene Daten ausgeben
                        if logWasSaved {
                            DispatchQueue.main.async {
                                self.reportProgressLogs(isSuccess: true)
                            }
                            let _ = data
                            //debugPrint(String(data: data, encoding: .utf8)!)
                        }
                        else {
                            print("Log was not saved correctly in core data")
                        }
                        
                    }
                    
                    // Data-Task muss via resume explizit gestartet werden
                    task.resume()
                    
                }
            }
            
        }
        else {
            print("incorrect URL!")
        }
        
    }
 
    
    
    
    @IBAction func uploadImagesClick(_ sender: Any) {
        
        //get all logs
        let tp_logs = getLogs()
        if !tp_logs.0 {
            showAlert(msg: "Error getting Logs: \(tp_logs.1)")
            return
        }
        
        //filter for logs with images
        logsWithImages = []
        for log in tp_logs.2 {
            let imgKey = log.image1!
            if imgKey != "" {
                logsWithImages.append(log)
            }
        }
        if logsWithImages.count == 0 {
            showAlert(msg: "No Pictures in Logs included")
            return
        }
        
        
        
        
        //reset control variables
        imgDone = false
        imgIndex = 0
        imgSuccess = 0
        imgError = 0
        imgTotal = logsWithImages.count
        statusLabel.text = "Uploading \(imgTotal) Images"
        
        startImgUpload()
    }
    
    
    
    //get already upload picture names from server, then continue handling upload
    func startImgUpload() {
           
        let url = URL(string: "https://cyclocrossingborders.de/getImageNames.php")!
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: url) { (data, response, error) in

            // Fehlerbehandlung für den Fall, das ein Fehler aufgetreten ist oder data nicht gesetzt ist
            guard let data = data, error == nil else {
                debugPrint("Fehler beim Laden von \(url)", String(describing: error))
                return
            }

            // Geladene Daten ausgeben
            //debugPrint(String(data: data, encoding: .utf8)!)
            print("Successfully retrieved already uploaded image names from server")
            self.alreadyUploadedPictures = String(data: data, encoding: .utf8)!
            self.handleImgUpload()
               
        }

        // Data-Task muss via resume explizit gestartet werden
        task.resume()
    }
    
    
    
    func handleImgUpload() {
        
        imgPackInit = 0
        imgPackSuccess = 0
        
        while true {
            
            if imgIndex == logsWithImages.count {
                return //finished
            }
            
            let log = logsWithImages[imgIndex]
            let imgKey = log.image1!
            
            //check if img is already uploaded
            if !alreadyUploadedPictures.contains(imgKey) {
                    
                //upload only a certain amount per request
                if imgPackInit == imgPackSize {
                    return
                }
                
                print("\(imgIndex) - \(imgPackInit) - \(imgKey)")
                
                let tp_retrieve = retrieveImage(forKey: imgKey)
                if (!tp_retrieve.0){
                    showAlert(msg: "Error getting Image from Disk: \(tp_retrieve.1)")
                    return
                }
                uploadImage(img: tp_retrieve.2!, imgKey: imgKey)
                imgPackInit = imgPackInit + 1
                   
            }
            else {
                print("\(imgIndex) -   - \(imgKey) already uploaded")
                imgSuccess = imgSuccess + 1
            }
            
            imgIndex = imgIndex + 1
        }
        
    }
    
    
    func uploadImage(img: UIImage, imgKey: String) {
        
        let myUrl = NSURL(string: "https://cyclocrossingborders.de/uploadPicture.php");
            
        let request = NSMutableURLRequest(url:myUrl! as URL)
        request.httpMethod = "POST"
        request.timeoutInterval = 720
        
        let param = [
            "firstName"  : "Hannes",
            "lastName"    : "Schaletzky",
            "userId"    : "17"
        ]
            
        let boundary = generateBoundaryString()
            
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
        let imageData = img.jpegData(compressionQuality: 1)
            
        if imageData == nil  {
            return
        }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary, imgKey: imgKey) as Data
            
        uploadQueue.async {
          do {
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                    
                    if error != nil {
                        DispatchQueue.main.async {
                            self.reportProgressPics(isSuccess: false)
                        }
                        print("error=\(error!)")
                        return
                    }
                    
                    //print response
                    //print("response = \(response!)")
                    
                    // print reponse body
                    //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //print("response data = \(responseString!)")
                
                    DispatchQueue.main.async {
                        self.reportProgressPics(isSuccess: true)
                    }
                    
                }
                
                task.resume()
            }
            
          }
        
        }
        
        
        
    
    
        
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String, imgKey: String) -> NSData {
            let body = NSMutableData();
            
            if parameters != nil {
                for (key, value) in parameters! {
                    body.appendString(string: "--\(boundary)\r\n")
                    body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString(string: "\(value)\r\n")
                }
            }
           
            let filename = "\(imgKey).jpg"
            let mimetype = "image/jpg"
                    
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey as Data)
            body.appendString(string: "\r\n")
            body.appendString(string: "--\(boundary)--\r\n")
            
            return body
        }
        
        func generateBoundaryString() -> String {
            return "Boundary-\(NSUUID().uuidString)"
        }
     
    
    
        func showAlert(msg: String) {
            let alert = UIAlertController(title: "Cycle Log", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    //implement ok action
            }))
            self.present(alert, animated: true, completion: nil)
        }


        // MARK: - Navigation
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if (segue.identifier == "showJourney") {
                let journeyVC = (segue.destination as! JourneyViewController)
                journeyVC.profileVC = self
            }
            
        }
    
    
    }

    extension NSMutableData {
        func appendString(string: String) {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            append(data!)
        }
    }










