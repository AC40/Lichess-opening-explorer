//
//  Settings.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 19.12.22.
//

import Foundation

 class Settings: ObservableObject {

     @Published var animatePieces = true
     @Published var animationSpeed: Double = 2

     //TODO: Create defaults and give option to reset to them
     
     //Future settings options:
     /*
      - App theme
        - predefined
        - customizable
      - Move notation system
      
      
      */
 }
