//
//  LogScreenTableViewController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 07.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//


import UIKit
import Foundation

class LogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelMood: UILabel!
    @IBOutlet weak var viewMood: UIView!
    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var iconImageAvailable: UIImageView!
    @IBOutlet weak var iconIsSynced: UIImageView!
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelKmCount: UILabel!
}

class LogTableViewController: UITableViewController {

    var logVC: LogViewController?
    
    var logs:[Log] = []
    
    //will be set by switch of LogViewController
    var loadImage = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func refreshData() {
        
        var _logs:[Log] = []
        logs.removeAll()
        
        //get _logs from core data
        let tp_getLogs = getLogs()
        if (!tp_getLogs.0) {
            logs = []
            showAlert(msg: "Error getting Logs \(tp_getLogs.1)")
            tableView.reloadData()
            return
        }
        //assign logs
        _logs = tp_getLogs.2
        
        //filter for selected journey
        for _log in _logs {
            if (_log.journey == gl_selectedJourney) {
                logs.append(_log)
            }
        }
        
        logVC?.labelLogCount.text = "\(logs.count)"
        tableView.reloadData()
    }
    
    
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Cycle Log", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                //implement ok action
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    
    //cell.logImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    
    
    //sun.max.fill
    //moon.zzz.fill
    //mappin.and.ellipse
    //person.2.fill
    //d.square
    //f.square
    //house.fill
    //photo
    //globe
    
    //paperplane
    //paperplane.fill
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogTableViewCell
        
        //get log
        let log = logs[indexPath.row]
        
        //mood
        //cell.labelMood.text = String(format: "%.0f", log.mood)
        cell.labelMood.text = ""
        cell.viewMood.layer.cornerRadius = 3
        
        let aFull = CGFloat(1.0)
        /*
        let col10 = UIColor(red: 0, green: 240, blue: 0, a: aFull)
        let col9  = UIColor(red: 80, green: 220, blue: 0, a: aFull)
        let col8  = UIColor(red: 160, green: 200, blue: 0, a: aFull)
        let col7  = UIColor(red: 255, green: 200, blue: 0, a: aFull)
        let col6  = UIColor(red: 255, green: 180, blue: 0, a: aFull)
        let col5  = UIColor(red: 255, green: 160, blue: 0, a: aFull)
        let col4  = UIColor(red: 255, green: 140, blue: 0, a: aFull)
        let col3  = UIColor(red: 255, green: 120, blue: 0, a: aFull)
        let col2  = UIColor(red: 255, green: 100, blue: 0, a: aFull)
        let col1  = UIColor(red: 255, green: 80, blue: 0, a: aFull)
        let col0  = UIColor(red: 255, green: 60, blue: 0, a: aFull)
        */
        let col10 = UIColor(red: 0, green: 240, blue: 0, a: aFull)
        let col9  = UIColor(red: 80, green: 220, blue: 0, a: aFull)
        let col8  = UIColor(red: 160, green: 240, blue: 0, a: aFull)
        let col7  = UIColor(red: 255, green: 255, blue: 0, a: aFull)
        let col6  = UIColor(red: 255, green: 240, blue: 0, a: aFull)
        let col5  = UIColor(red: 255, green: 220, blue: 0, a: aFull)
        let col4  = UIColor(red: 255, green: 170, blue: 0, a: aFull)
        let col3  = UIColor(red: 255, green: 130, blue: 0, a: aFull)
        let col2  = UIColor(red: 255, green: 100, blue: 0, a: aFull)
        let col1  = UIColor(red: 255, green: 70, blue: 0, a: aFull)
        let col0  = UIColor(red: 255, green: 40, blue: 0, a: aFull)
        
        switch log.mood {
        case 10:
            cell.viewMood.backgroundColor = col10
        case 9:
            cell.viewMood.backgroundColor = col9
        case 8:
            cell.viewMood.backgroundColor = col8
        case 7:
            cell.viewMood.backgroundColor = col7
        case 6:
            cell.viewMood.backgroundColor = col6
        case 5:
            cell.viewMood.backgroundColor = col5
        case 4:
            cell.viewMood.backgroundColor = col4
        case 3:
            cell.viewMood.backgroundColor = col3
        case 2:
            cell.viewMood.backgroundColor = col2
        case 1:
            cell.viewMood.backgroundColor = col1
        case 0:
            cell.viewMood.backgroundColor = col0
        default:
            cell.viewMood.backgroundColor = UIColor.clear
        }
        
        
        //kmCount - only for day end
        if log.type == Log.Type_DayEnd {
            cell.labelKmCount.text = "\(log.kmCount)"
        }
        else {
            cell.labelKmCount.text = " "
        }
        
        //distance - not for first row
        if indexPath.row > 0 {
            let log1 = logs[indexPath.row - 1]
            let log2 = logs[indexPath.row]
            let distance = getDistanceBetweenLogs(log1: log1, log2: log2)
            cell.labelDistance.text = "\(distance)"
        }
        else {
            cell.labelDistance.text = ""
        }
        
        
        //date 12.05.2020
        var subDate = ""
        if log.type == Log.Type_JourneyStart || log.type == Log.Type_JourneyEnd {
            //display year for journey start and end
            subDate = log.date + " - "
        }
        else if log.type == Log.Type_DayStart {
            subDate = log.date.substring(to: 4) + " - "
        }
        cell.labelDate.text = subDate
        
        //time 12:45:04
        let subTime = log.time.substring(to: 4)
        cell.labelTime.text = subTime
        
        //Icon type
        let tpIcon = Log.getIconFor(logType: log.type)
        if tpIcon.0 != "" {
            cell.imageType.image = UIImage(systemName: tpIcon.0)
            cell.imageType.tintColor = tpIcon.1
        }
        else {
            cell.imageType.image = nil
            cell.imageType.tintColor = UIColor.systemBackground
        }
        
        //Icon image
        if log.image1 != "" {
            cell.iconImageAvailable.tintColor = UIColor.systemGray2
        }
        else {
            cell.iconImageAvailable.tintColor = UIColor.clear
        }
        
        //Icon isSynced
        if log.isSynced {
            cell.iconIsSynced.image = UIImage(systemName: "paperplane.fill")
        }
        else {
            cell.iconIsSynced.image = UIImage(systemName: "paperplane")
        }
        

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let log = logs[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (tableView.isEditing) {
            //edit
            logVC?.editLog(logToEdit: log)
        }
        else {
            //show only
            logVC?.showLog(logToShow: log)
        }
        
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let tp_del = deleteLog(logToDelete: logs[indexPath.row])
            if (!tp_del.0) {
                logVC?.showAlert(msg: "deletion in storage failed: \(tp_del.1)")
            }
            else {
                logs.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                logVC?.labelLogCount.text = "\(logs.count)"
            }
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
