//
//  Fit_TrackingV2App.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import SwiftUI
import Firebase

@main
struct Fit_TrackingApp: App {
    init() {
           FirebaseApp.configure() // 👈 Esto inicializa Firebase al arrancar la app
       }
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
