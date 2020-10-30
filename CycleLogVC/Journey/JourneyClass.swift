//
//  JourneyClass.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 06.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import Foundation

class Journey {
    
    var name: String
    var creationDate: Date
    
    
    init(name: String) {
        //given values
        self.name = name
        
        //automatic values
        creationDate = Date()
        
    }
    
    
    
}
