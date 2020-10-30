//
//  JourneyViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 06.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

var gl_journeys: [Journey] = []
var gl_selectedJourney = "" 

class JourneyViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldName: UITextField!
    
    //Embedded TableVC
    var journeyTableVC: JourneyTableViewController?
    //Calling VC
    var profileVC: ProfileViewController?
    var addVC: AddViewController?
    var logVC: LogViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        let tp_journeys = getJourneys()
        if (!tp_journeys.0) {
            showAlert(msg: "Error getting Journeys")
            dismissClick()
        }
        gl_journeys = tp_journeys.1
        journeyTableVC?.refreshTable()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true //disable swipe to dismiss
        textFieldName.delegate = self
    }
    
    
    @IBAction func addClick() {
        
        //check if empty
        let trimmedName = textFieldName.text?.trimmingCharacters(in: .whitespaces)
        if (trimmedName == "") {
            showAlert(msg: "Name empty")
            return
        }
        
        //check if journey exists
        for journey in gl_journeys {
            if (trimmedName?.lowercased() == journey.name.lowercased()) {
                showAlert(msg: "Name already exists")
                return
            }
        }
        
        
        //save to coredata
        let tp_save = saveJourney(name: trimmedName!)
        if (!tp_save.0) {
            showAlert(msg: "error saving journey \(tp_save.1)")
            return
        }
        
        let newJourney = Journey(name: trimmedName!)
        gl_journeys.append(newJourney)
        
        
        journeyTableVC?.refreshTable()
        journeyTableVC?.tableView.setEditing(false, animated: true)
        textFieldName.resignFirstResponder()
        textFieldName.text = ""
        
    }
    @IBAction func editClick(_ sender: Any) {
        journeyTableVC?.tableView.setEditing(!journeyTableVC!.tableView.isEditing, animated: true)
    }
    
    @IBAction func dismissClick() {
        
        //user deleted everything
        if (gl_journeys.count == 0) {
            gl_selectedJourney = ""
        }
        
        //user enters for first time and does not select anything
        var titleText = gl_selectedJourney
        if (titleText == "") {
            titleText = "Select Journey"
        }
        else {
            //user selected something
            saveJourneyToDefaults(journeyName: gl_selectedJourney)
        }
        
        addVC?.buttonJourney.setTitle(titleText, for: .normal)
        logVC?.buttonJourney.setTitle(titleText, for: .normal)
        profileVC?.buttonJourney.setTitle(titleText, for: .normal)
        logVC?.refreshTable()
        dismiss(animated: true, completion: nil)
    }
    
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Cycle Log", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                //implement ok action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //delegate to hide keyboard of textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        journeyTableVC = (segue.destination as! JourneyTableViewController)
        journeyTableVC?.journeyVC = self
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

}
