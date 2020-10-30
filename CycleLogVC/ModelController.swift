//
//  ModelController.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 06.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: - NS User Defaults

func saveJourneyToDefaults(journeyName:String) {
    let defaults = UserDefaults.standard
    defaults.set(journeyName, forKey: "Journey")
}

func retrieveJourneyFromDefaults() -> String {
    let defaults = UserDefaults.standard
    
    if let journeyName = defaults.string(forKey: "Journey") {
        return journeyName
    }
    else {
        return ""
    }
    
}







// MARK: - App Directory - Image

func saveImage(image: UIImage, forKey key: String) -> (Bool, String) {
    if let pngRepresentation = image.pngData() {
        if let filePath = getFilePath(forKey: key) {
            do  {
                try pngRepresentation.write(to: filePath,
                                            options: .atomic)
                return (true, "")
            } catch let err {
                print("error saveImage: \(err.localizedDescription)")
                return (false, err.localizedDescription)
            }
        }
    }
    return (false, "error in saveImage")
}

func retrieveImage(forKey key: String) -> (Bool, String, UIImage?) {
    if let filePath = getFilePath(forKey: key),
        let fileData = FileManager.default.contents(atPath: filePath.path),
        let image = UIImage(data: fileData) {
        return (true, "", image)
    }
    
    return (false, "no image found for: \(key)", nil)
}

func deleteImage(forKey key: String) -> (Bool, String){
    
    if let filePath = getFilePath(forKey: key) {
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
            print("removed image for key: \(key)")
            return (true, "")
        } catch let err {
            print("error deleteImage: \(err.localizedDescription)")
            return(false, err.localizedDescription)
        }
    }
    else {
        return (false, "could not get filePath")
    }
    
    
}

func getFilePath(forKey key: String) -> URL? {
    let fileManager = FileManager.default
    guard let documentURL = fileManager.urls(for: .documentDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
    
    return documentURL.appendingPathComponent(key + ".png")
}













// MARK: - Core Data - Journey

func saveJourney(name: String) -> (Bool, String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, "app delegate fetch fail")
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Journeys"
    
    guard let newEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
        return (false, "entitiy fetch fail")
    }
    
    let newJourney = NSManagedObject(entity: newEntity, insertInto: context)
    
    //automatic values
    let creationDate = Date()
    
    newJourney.setValue(name, forKey: "name")
    newJourney.setValue(creationDate, forKey: "creationDate")
    
    do {
        try context.save()
    } catch {
        print("ERROR WHILE SAVING")
    }
    
    return (true, "")
}



func getJourneys() -> (Bool,[Journey]) {
    
    var journeys: [Journey] = []
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, journeys)
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Journeys"
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    do {
        let results = try context.fetch(request)
        
        for r in results {
            if let result = r as? NSManagedObject {
                
                //extract attributes
                guard let journeyName = result.value(forKey: "name") as? String else {
                    return (false, journeys)
                }
                
                let newJourney = Journey(name: journeyName)
                
                journeys.append(newJourney)
            }
        }
        
        return (true, journeys)
        
    } catch {
        print("ERROR WHILE FETCH")
        return (false, journeys)
    }
}

func deleteJourney(journeyNameToDelete:String) -> (Bool, String){
    
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, "could not get app delegate")
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Journeys"
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    do {
        let results = try context.fetch(request)
        
        for r in results {
            if let result = r as? NSManagedObject {
                
                //EXTRACT
                guard let journeyName = result.value(forKey: "name") as? String else {
                    return (false, "could not extract journey name")
                }
                
                //MATCH
                if (journeyName == journeyNameToDelete) {
                    print("\(journeyNameToDelete) FOUND")
                    
                    //DELETE
                    context.delete(result)
                    
                    //SAVE
                    do {
                        try context.save()
                        return (true, "")
                    } catch {
                        return (true, "error while saving")
                    }
                }
                
                
            }
        }
        
        return (true, "")
        
    } catch {
        return (false, "error while fetch")
    }
    
}








// MARK: - Core Data - Logs

func saveLog(logToSave:Log) -> (Bool, String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, "app delegate fetch fail")
    }
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Logs"
    guard let newEntity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
        return (false, "entity fetch fail")
    }
    let newLog = NSManagedObject(entity: newEntity, insertInto: context)
    
    newLog.setValue(logToSave.journey, forKey: Log.AttName_Journey)
    newLog.setValue(logToSave.date, forKey: Log.AttName_Date)
    newLog.setValue(logToSave.time, forKey: Log.AttName_Time)
    newLog.setValue(logToSave.timeZone, forKey: Log.AttName_TimeZone)
    newLog.setValue(logToSave.type, forKey: Log.AttName_Type)
    newLog.setValue(logToSave.mood, forKey: Log.AttName_Mood)
    newLog.setValue(logToSave.kmCount, forKey: Log.AttName_KMCount)
    newLog.setValue(logToSave.lat, forKey: Log.AttName_Latitude)
    newLog.setValue(logToSave.lon, forKey: Log.AttName_Longitute)
    newLog.setValue(logToSave.horAcc, forKey: Log.AttName_HorAcc)
    newLog.setValue(logToSave.verAcc, forKey: Log.AttName_VerAcc)
    newLog.setValue(logToSave.image1, forKey: Log.AttName_Image1)
    newLog.setValue(logToSave.imgOrientation, forKey: Log.AttName_ImageOrientation)
    newLog.setValue(logToSave.note, forKey: Log.AttName_Note)
    newLog.setValue(logToSave.isSynced, forKey: Log.AttName_IsSynced)
    newLog.setValue(logToSave.isOfflineLog, forKey: Log.AttName_IsOfflineLog)
    newLog.setValue(logToSave.finalValues, forKey: Log.AttName_FinalValues)
    newLog.setValue(logToSave.other, forKey: Log.AttName_Other)
    
    do {
        try context.save()
    } catch {
        print("ERROR WHILE SAVING")
    }
    
    return (true, "")
    
}



func getLogs() -> (Bool, String, [Log]) {
    
    var logs:[Log] = []
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, "app delegate fetch fail", logs)
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Logs"
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    do {
        let results = try context.fetch(request)
        
        for r in results {
            if let result = r as? NSManagedObject {
                
                //extract data
                guard let journey = result.value(forKey: Log.AttName_Journey) as? String else {
                    return (false, "fail extract \(Log.AttName_Journey)", logs)
                }
                
                guard let type = result.value(forKey: Log.AttName_Type) as? String else {
                    return (false, "fail extract \(Log.AttName_Type)", logs)
                }
                
                guard let date = result.value(forKey: Log.AttName_Date) as? String else {
                    return (false, "fail extract \(Log.AttName_Date)", logs)
                }
                
                guard let time = result.value(forKey: Log.AttName_Time) as? String else {
                    return (false, "fail extract \(Log.AttName_Time)", logs)
                }
                
                guard let timeZone = result.value(forKey: Log.AttName_TimeZone) as? String else {
                    return (false, "fail extract \(Log.AttName_TimeZone)", logs)
                }
                
                guard let lat = result.value(forKey: Log.AttName_Latitude) as? Double else {
                    return (false, "fail extract \(Log.AttName_Latitude)", logs)
                }
                
                guard let lon = result.value(forKey: Log.AttName_Longitute) as? Double else {
                    return (false, "fail extract \(Log.AttName_Longitute)", logs)
                }
                
                guard let horAcc = result.value(forKey: Log.AttName_HorAcc) as? Double else {
                    return (false, "fail extract \(Log.AttName_HorAcc)", logs)
                }
                
                guard let verAcc = result.value(forKey: Log.AttName_VerAcc) as? Double else {
                    return (false, "fail extract \(Log.AttName_VerAcc)", logs)
                }
                
                guard let mood = result.value(forKey: Log.AttName_Mood) as? Int else {
                    return (false, "fail extract \(Log.AttName_Mood)", logs)
                }
                
                guard let img1 = result.value(forKey: Log.AttName_Image1) as? String else {
                    return (false, "fail extract \(Log.AttName_Image1)", logs)
                }
                
                guard let imgOrient = result.value(forKey: Log.AttName_ImageOrientation) as? String else {
                    return (false, "fail extract \(Log.AttName_ImageOrientation)", logs)
                }
                
                guard let isSynced = result.value(forKey: Log.AttName_IsSynced) as? Bool else {
                    return (false, "fail extract \(Log.AttName_IsSynced)", logs)
                }
                
                guard let kmCount = result.value(forKey: Log.AttName_KMCount) as? Int else {
                    return (false, "fail extract \(Log.AttName_KMCount)", logs)
                }
                
                guard let isOfflineLog = result.value(forKey: Log.AttName_IsOfflineLog) as? Bool else {
                    return (false, "fail extract \(Log.AttName_IsOfflineLog)", logs)
                }
                
                guard let note = result.value(forKey: Log.AttName_Note) as? String else {
                    return (false, "fail extract \(Log.AttName_Note)", logs)
                }
                
                guard let finalValues = result.value(forKey: Log.AttName_FinalValues) as? String else {
                    return (false, "fail extract \(Log.AttName_IsSynced)", logs)
                }
                
                guard let other = result.value(forKey: Log.AttName_Other) as? String else {
                    return (false, "fail extract \(Log.AttName_Other)", logs)
                }
                
                let tpDateTime = (date, time, timeZone)
                let tpLocation = (lat, lon, horAcc, verAcc)
                
                let newLog = Log(journey: journey, tpDateTime: tpDateTime, type: type, mood: mood, kmCount: kmCount, tpLocation: tpLocation, image1: img1, imgOrientation: imgOrient, note: note, isSynced: isSynced, isOfflineLog: isOfflineLog, finalValues: finalValues, other: other)
                
                logs.append(newLog)
            }
        }
        
        return (true, "", logs)
        
    } catch {
        return (false, "ERROR WHILE FETCH", logs)
    }
}





func deleteLog(logToDelete:Log) -> (Bool, String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, "app delegate fetch fail")
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Logs"
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    do {
        let results = try context.fetch(request)
        
        for r in results {
            if let result = r as? NSManagedObject {
                
                //EXTRACT
                guard let date = result.value(forKey: Log.AttName_Date) as? String else {
                    return (false, "fail extract \(Log.AttName_Date)")
                }
                
                guard let time = result.value(forKey: Log.AttName_Time) as? String else {
                    return (false, "fail extract \(Log.AttName_Time)")
                }
                
                //MATCH
                if (logToDelete.date == date && logToDelete.time == time) {
                    print("logToDelete (\(date) - \(time)) FOUND")
                    
                    //DELETE PICTURE
                    if let imgKey = result.value(forKey: Log.AttName_Image1) as? String {
                        if (imgKey != "") {
                            let tp_imgDel = deleteImage(forKey: imgKey)
                            if (!tp_imgDel.0) {
                                return (false, "image deletion fail: \(tp_imgDel.1)")
                            }
                        }
                    }
                    else {
                        return (false, "fail extract \(Log.AttName_Image1)")
                    }
                    
                    //DELETE
                    context.delete(result)
                    
                    //SAVE
                    do {
                        try context.save()
                        return (true, "")
                    } catch {
                        return (true, "error while saving")
                    }
                }
                
                
            }
        }
        
        return (true, "")
        
    } catch {
        return (false, "error while fetch")
    }
}





func editLog(newLog:Log) -> (Bool, String) {
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return (false, "app delegate fetch fail")
    }
    
    let context = appDelegate.persistentContainer.viewContext
    let entityName = "Logs"
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    do {
        let results = try context.fetch(request)
        
        for r in results {
            if let result = r as? NSManagedObject {
                
                //EXTRACT
                guard let date = result.value(forKey: Log.AttName_Date) as? String else {
                    return (false, "fail extract \(Log.AttName_Date)")
                }
                
                guard let time = result.value(forKey: Log.AttName_Time) as? String else {
                    return (false, "fail extract \(Log.AttName_Time)")
                }
                
                //MATCH
                if (newLog.date == date && newLog.time == time) {
                    //print("logToEdit (\(date) - \(time)) FOUND")
                    
                    //dont update date time, since its ID key
                    //result.setValue(logToSave.date, forKey: Log.AttName_Date)
                    //result.setValue(logToSave.time, forKey: Log.AttName_Time)
                    //result.setValue(logToSave.timeZone, forKey: Log.AttName_TimeZone)
                    
                    //UPDATE
                    result.setValue(newLog.journey, forKey: Log.AttName_Journey)
                    result.setValue(newLog.type, forKey: Log.AttName_Type)
                    result.setValue(newLog.mood, forKey: Log.AttName_Mood)
                    result.setValue(newLog.kmCount, forKey: Log.AttName_KMCount)
                    result.setValue(newLog.lat, forKey: Log.AttName_Latitude)
                    result.setValue(newLog.lon, forKey: Log.AttName_Longitute)
                    result.setValue(newLog.horAcc, forKey: Log.AttName_HorAcc)
                    result.setValue(newLog.verAcc, forKey: Log.AttName_VerAcc)
                    result.setValue(newLog.image1, forKey: Log.AttName_Image1)
                    result.setValue(newLog.imgOrientation, forKey: Log.AttName_ImageOrientation)
                    result.setValue(newLog.note, forKey: Log.AttName_Note)
                    result.setValue(newLog.isSynced, forKey: Log.AttName_IsSynced)
                    result.setValue(newLog.isOfflineLog, forKey: Log.AttName_IsOfflineLog)
                    result.setValue(newLog.finalValues, forKey: Log.AttName_FinalValues)
                    result.setValue(newLog.other, forKey: Log.AttName_Other)
                    
                    //SAVE
                    do {
                        try context.save()
                        return (true, "")
                    } catch {
                        return (true, "error while saving")
                    }
                }
                
                
            }
        }
        
        return (true, "")
        
    } catch {
        return (false, "error while fetch")
    }
}

