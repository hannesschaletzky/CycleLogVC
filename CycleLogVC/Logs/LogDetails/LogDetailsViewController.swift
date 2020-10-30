//
//  LogDetailsViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 17.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

class LogDetailsViewController: UIViewController {

    var logVC: LogViewController?
    
    @IBOutlet weak var labelTypeMood: UILabel!
    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSynced: UIImageView!
    @IBOutlet weak var labelLat: UILabel!
    @IBOutlet weak var labelLon: UILabel!
    @IBOutlet weak var labelAcc: UILabel!
    @IBOutlet weak var labelDateTime: UILabel!
    @IBOutlet weak var labelKmCount: UILabel!
    
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewCenterVertically: NSLayoutConstraint!
    
    var log: Log!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = false //enable swipe to dismiss
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateView()
    }
    
    
    func populateView() {
        
        labelTypeMood.text = "\(log.type) - \(log.mood)"
        
        //type icon
        let tpIcon = Log.getIconFor(logType: log.type)
        if tpIcon.0 != "" {
            imageType.image = UIImage(systemName: tpIcon.0)
            imageType.tintColor = tpIcon.1
        }
        else {
            imageType.image = nil
            imageType.tintColor = UIColor.systemBackground
        }
        
        //synced icon
        if log.isSynced {
            imageSynced.image = UIImage(systemName: "paperplane.fill")
        }
        else {
            imageSynced.image = UIImage(systemName: "paperplane")
        }
        
        //IMAGE
        if log.image1 != "" {
            let tpImg = retrieveImage(forKey: log.image1!)
            if (!tpImg.0) {
                imageView.image = nil
                showAlert(msg: "Error retrieving image.")
            }
            else {
                
                print("Orientation: \(log.imgOrientation!)")
                let rotValue = getRotationValueFor(orientationDef: log.imgOrientation!)
                
                imageView.transform = CGAffineTransform(rotationAngle: rotValue)
                imageView.image = tpImg.2
                imageView.isUserInteractionEnabled = true
            }
        }
        else {
            imageView.image = nil
            
        }
        
        labelLat.text = "Latitude:  \(log.lat)"
        labelLon.text = "Longitude: \(log.lon)"
        labelAcc.text = "Accuracy: (Hor)\(log.horAcc); (Ver)\(log.verAcc)"
        labelDateTime.text = "Date: \(log.date) - \(log.time) - \(log.timeZone)"
        labelKmCount.text = "km: \(log.kmCount)"
    }
    
    @IBAction func imageTapped(_ sender: Any) {
        
        if imageViewTop.isActive {
            print("set full screen")
            imageViewTop.isActive = false
            imageViewCenterVertically.isActive = true
            imageViewWidth.constant = CGFloat(UIScreen.main.bounds.width)
            imageViewHeight.constant = CGFloat(UIScreen.main.bounds.height)
        }
        else {
            //set back to 240x240
            print("set back to 240x240")
            imageViewTop.isActive = true
            imageViewCenterVertically.isActive = false
            imageViewWidth.constant = CGFloat(240)
            imageViewHeight.constant = CGFloat(240)
        }
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    @IBAction func buttonDismissClick() {
        dismiss(animated: true, completion: nil)
    }
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Cycle Log", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                //implement ok action
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
