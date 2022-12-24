//
//  SettingsView.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 19.12.22.
//

import SwiftUI

struct SettingsView: View {

     @EnvironmentObject var settings: Settings
     @Environment(\.dismiss) var dismiss

     @State private var animatePieces: Bool = false
     @State private var animationSpeed: Double = 0

     var body: some View {
         NavigationView {
             Form {

                 Group {
                     Toggle("Animate pieces", isOn: $animatePieces)

                     if animatePieces {
                         VStack {
                             Slider(value: $animationSpeed) {
                                 Text("Animation speed")
                             }
                         }
                     }
                 }
                 .animation(.default, value: animatePieces)

             }
             .navigationTitle("Settings")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(id: "cancelBtn", placement: .cancellationAction) {
                     Button("Cancel") {
                         dismiss()
                     }
                 }
                 ToolbarItem(id: "submitBtn", placement: .primaryAction) {
                     Button("Submit") {
                         submitForm()
                         dismiss()
                     }
                 }
             }
             .task {
                 initValues()
             }
         }
     }

     func initValues() {
         animatePieces = settings.animatePieces
         animationSpeed = settings.animationSpeed * 0.25
     }

     func submitForm() {
         settings.animatePieces = animatePieces
         settings.animationSpeed = animationSpeed * 4
     }
 }

 struct SettingsView_Previews: PreviewProvider {
     static var previews: some View {
         SettingsView()
     }
 }
