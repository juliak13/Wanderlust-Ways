//
//  ContentView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if let user = viewModel.userSession {
                MainTabView(userId: user.uid) // Pass the userId to MainTabView
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
