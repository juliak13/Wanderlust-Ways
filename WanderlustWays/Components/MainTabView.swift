//
//  TabView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI

struct MainTabView: View {
    var userId: String // Add this property to reference the user

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            PlanTripView(userId: userId)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Plan Trip")
                }
            //TripListView(userId: userId)
            //    .tabItem {
            //        Image(systemName: "list.bullet")
            //        Text("Trips")
            //    }
            
            let sampleTrip = Trip(destination: "Paris", startDate: Date(), endDate: Date(), transportType: "Plane")
            
            //ItineraryView(trip: sampleTrip)
            //    .tabItem {
            //        Image(systemName: "calendar")
            //        Text("Itinerary")
            //    }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(userId: "exampleUserId")
    }
}
