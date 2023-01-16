//
//  Settings.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 19.12.22.
//

import SwiftUI

 class Settings: ObservableObject {

     @Published var animatePieces = true
     @Published var animationSpeed: Double = 2

     
     func movePieceAnimation() -> Animation {
         guard animatePieces else {
             return Animation.linear(duration: 0)
         }

         return Animation.linear.speed(animationSpeed)
     }
     
     //Future settings options:
     /*
      - App theme
        - predefined
        - customizable
      - Move notation system
      
      
      */
 }
