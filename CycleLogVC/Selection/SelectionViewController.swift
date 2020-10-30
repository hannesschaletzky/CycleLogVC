//
//  SelectionViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 16.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

var gl_selectedLogType = "" 
let gl_logTypes = [Log.Type_JourneyStart,
                   Log.Type_JourneyEnd,
                   Log.Type_DayStart,
                   Log.Type_DayEnd,
                   Log.Type_Checkpoint,
                   Log.Type_Drink,
                   Log.Type_Food,
                   Log.Type_Stay,
                   Log.Type_Photo,
                   Log.Type_Friends]

struct TypeSelectionCaller {
    static let addLog = "addLog"
    static let editLog = "editLog"
}

class SelectionViewController: UIViewController {

    var addVC:AddViewController?
    var logEditVC:LogEditViewController?
    var selectionTableVC:SelectionTableViewController?
    var caller:String! //TypeSelectionCaller
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true //disable swipe to dismiss
    }
    
    @IBAction func buttonDismissClick() {
        
        if (caller == TypeSelectionCaller.addLog) {
            addVC?.buttonType.setTitle(gl_selectedLogType, for: .normal)
            addVC?.handleTextFieldVisibility()
        }
        else if (caller == TypeSelectionCaller.editLog) {
            logEditVC?.buttonType.setTitle(gl_selectedLogType, for: .normal)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedTableSelection") {
            let selectionTableVC = (segue.destination as! SelectionTableViewController)
            self.selectionTableVC = selectionTableVC
            selectionTableVC.selectionVC = self
        }
    }
    

}
