//
//  WanderlustWaysApp.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI
import Firebase


@main
struct WanderlustWaysApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
