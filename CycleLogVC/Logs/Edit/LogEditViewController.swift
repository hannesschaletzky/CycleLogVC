//
//  LogEditViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 19.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

class LogEditViewController: UIViewController {

    var logVC:LogViewController?
    var selectionVC:SelectionViewController?
    
    @IBOutlet weak var buttonType: UIButton!
    
    var log: Log!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true //disable swipe to dismiss
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateView()
    }
    
    func populateView() {
        
        //log type
        buttonType.setTitle(log.type, for: .normal)
        
    }
    
    
    @IBAction func cancelClick() {
        let cancelAlert = UIAlertController(title: "Cancel?", message: "Changes will be discarded", preferredStyle: UIAlertController.Style.alert)
        cancelAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
          }))
        cancelAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
          }))
        present(cancelAlert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func saveClick() {
        
        
        
        if let newType = buttonType.titleLabel?.text {
            log.type = newType
        }
        else {
            showAlert(msg: "Error getting Log Type from Screen")
            return
        }
        
        
        
        let tpSaveEdit = editLog(newLog: log)
        if (!tpSaveEdit.0) {
            showAlert(msg: "Error updating Log in Database: \(tpSaveEdit.1)")
            return
        }
        
        logVC?.refreshTable()
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Cycle Log", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "editType") {
            let selectionVC = (segue.destination as! SelectionViewController)
            self.selectionVC = selectionVC
            selectionVC.logEditVC = self
            selectionVC.caller = TypeSelectionCaller.editLog
        }
        
    }
    

}
