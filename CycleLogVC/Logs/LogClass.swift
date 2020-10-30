//
//  LogClass.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 07.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import Foundation
import UIKit

class Log {
    
    static let Type_JourneyStart = "JourneyStart"
    static let Type_JourneyEnd = "JourneyEnd"
    static let Type_DayStart = "DayStart"
    static let Type_DayEnd = "DayEnd"
    static let Type_Checkpoint = "Checkpoint"
    static let Type_Drink = "Drink"
    static let Type_Food = "Food"
    static let Type_Stay = "Stay"
    static let Type_Photo = "Photo"
    static let Type_Friends = "Friends"
    
    /*
     journey,
     date,
     time,
     timeZone,
     type,
     mood,
     kmCount,
     longitute,
     latitude,
     horAcc,
     verAcc,
     image1,
     imgOrientation,
     note,
     isSynced,
     isOfflineLog,
     finalValues,
     other
     */
    
    static let AttName_Journey = "journey"
    static let AttName_Date = "date"
    static let AttName_Time = "time"
    static let AttName_TimeZone = "timeZone"
    static let AttName_Type = "type"
    static let AttName_Mood = "mood"
    static let AttName_KMCount = "kmCount"
    static let AttName_Longitute = "longitute"
    static let AttName_Latitude = "latitude"
    static let AttName_HorAcc = "horAcc"
    static let AttName_VerAcc = "verAcc"
    static let AttName_Image1 = "image1"
    static let AttName_ImageOrientation = "imgOrientation"
    static let AttName_Note = "note"
    static let AttName_IsSynced = "isSynced"
    static let AttName_IsOfflineLog = "isOfflineLog"
    static let AttName_FinalValues = "finalValues"
    static let AttName_Other = "other"
    
    var journey:String
    var date:String
    var time:String
    var timeZone:String
    var type:String
    var mood:Int
    var kmCount:Int
    var lat:Double      //latitude
    var lon:Double      //longitute
    var horAcc:Double
    var verAcc:Double
    var image1:String?          //optional
    var imgOrientation:String?  //optional
    var note:String
    var isSynced:Bool
    var isOfflineLog:Bool
    var finalValues:String
    var other:String
    
    init(journey:String, tpDateTime:(String, String, String), type:String, mood:Int, kmCount:Int, tpLocation:(Double, Double, Double, Double), image1:String, imgOrientation:String, note:String, isSynced:Bool, isOfflineLog:Bool, finalValues:String, other:String) {
        
        //tpLocation = (lat, lon, horAcc, verAcc)
        //tpDateTime = (date, time, timeZone)
        
        self.journey = journey
        self.date = tpDateTime.0
        self.time = tpDateTime.1
        self.timeZone = tpDateTime.2
        self.type = type
        self.mood = mood
        self.kmCount = kmCount
        self.lat = tpLocation.0
        self.lon = tpLocation.1
        self.horAcc = tpLocation.2
        self.verAcc = tpLocation.3
        self.image1 = image1
        self.imgOrientation = imgOrientation
        self.note = note
        self.isSynced = isSynced
        self.isOfflineLog = isOfflineLog
        self.finalValues = finalValues
        self.other = other
        
    }
    
    
    static func getIconFor(logType: String) -> (String, UIColor) {
        
        if (logType == Log.Type_JourneyStart || logType == Log.Type_JourneyEnd) {
            return ("globe", UIColor.systemGray)
        }
        else if (logType == Log.Type_DayStart) {
            return ("sun.max.fill", UIColor.systemYellow)
        }
        else if (logType == Log.Type_DayEnd) {
            return ("moon.zzz.fill", UIColor.black)
        }
        else if (logType == Log.Type_Checkpoint) {
            return ("mappin.and.ellipse", UIColor.lightGray)
        }
        else if (logType == Log.Type_Drink) {
            return ("d.square", UIColor.lightGray)
        }
        else if (logType == Log.Type_Food) {
            return ("f.square", UIColor.lightGray)
        }
        else if (logType == Log.Type_Stay) {
            return ("house.fill", UIColor.lightGray)
        }
        else if (logType == Log.Type_Friends) {
            return ("person.2.fill", UIColor.lightGray)
        }
        else if (logType == Log.Type_Photo) {
            return ("photo", UIColor.lightGray)
        }
        
        return ("", UIColor.systemBackground)
        
    }
    
}
