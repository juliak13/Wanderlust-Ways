//
//  HomeView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct HomeView: View {
    @State private var upcomingTrips: [Trip] = []
    @State private var id: String = "currentUserId" // Replace with actual user ID
    
    var body: some View {
        NavigationView {
            VStack {
                // App Name and Logo
                VStack {
                    HStack {
                        Image("wwlogo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                        Text("Wanderlust Ways")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                }
                
                // Upcoming Trips Section
                VStack(alignment: .leading) {
                    Text("Upcoming Trips")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading)
                    
                    List(upcomingTrips) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            VStack(alignment: .leading) {
                                Text(trip.destination)
                                    .font(.headline)
                                Text("\(trip.startDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(trip.endDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .onAppear(perform: fetchUpcomingTrips)
                
                Spacer()
            }
        }
    }
    
    func fetchUpcomingTrips() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user is currently logged in.")
            return
        }
        print("DEBUG: Fetching trips for user ID: \(userId)")
        
        FirebaseManager.shared.firestore.collection("users").document(userId).collection("trips").getDocuments { (snapshot, error) in
            if let error = error {
                print("DEBUG: Error fetching trips: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                self.upcomingTrips = snapshot.documents.compactMap { document in
                    try? document.data(as: Trip.self)
                }
                print("DEBUG: Fetched \(self.upcomingTrips.count) trips.")
            } else {
                print("DEBUG: No snapshot found.")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
