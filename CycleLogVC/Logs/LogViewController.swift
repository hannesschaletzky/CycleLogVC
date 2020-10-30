//
//  LogViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 12.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {

    var logTableVC: LogTableViewController!
    var logDetailsVC: LogDetailsViewController?
    var logEditVC: LogEditViewController?
    
    @IBOutlet weak var buttonJourney: UIButton!
    @IBOutlet weak var labelLogCount: UILabel!
    
    var selectedLog: Log!
    
    override func viewWillAppear(_ animated: Bool) {
        if (gl_selectedJourney == "") {
            buttonJourney.setTitle("Select Journey", for: .normal)
        }
        else {
            buttonJourney.setTitle(gl_selectedJourney, for: .normal)
        }
        logTableVC.tableView.setEditing(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func refreshTable() {
        logTableVC.tableView.setEditing(false, animated: true)
        logTableVC.refreshData()
    }

    @IBAction func editClick() {
        logTableVC.tableView.setEditing(!logTableVC.tableView.isEditing, animated: true)
    }
    
    func showLog(logToShow:Log) {
        selectedLog = logToShow
        performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    func editLog(logToEdit:Log) {
        selectedLog = logToEdit
        performSegue(withIdentifier: "showEdit", sender: nil)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showJourney") {
            let journeyVC = (segue.destination as! JourneyViewController)
            journeyVC.logVC = self
        }
        else if (segue.identifier == "embedTable") {
            let logTableVC = (segue.destination as! LogTableViewController)
            self.logTableVC = logTableVC
            logTableVC.logVC = self
        }
        else if (segue.identifier == "showDetails") {
            let logDetailsVC = (segue.destination as! LogDetailsViewController)
            self.logDetailsVC = logDetailsVC
            logDetailsVC.log = selectedLog
            logDetailsVC.logVC = self
        }
        else if (segue.identifier == "showEdit") {
            let logEditVC = (segue.destination as! LogEditViewController)
            self.logEditVC = logEditVC
            logEditVC.log = selectedLog
            logEditVC.logVC = self
        }
        
        
        
        
        
        
        
        
    }
    

}
