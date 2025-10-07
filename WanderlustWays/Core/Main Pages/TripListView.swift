//
//  TripListView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TripListView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var userId: String // Add this property to reference the user
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading trips...")
            } else if trips.isEmpty {
                Text("No trips available.")
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(trips) { trip in
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            VStack(alignment: .leading) {
                                Text(trip.destination)
                                Text("\(trip.startDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(trip.endDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteTrip)
                }
            }
        }
        .onAppear(perform: fetchTrips)
        .navigationTitle("Your Trips")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func fetchTrips() {
        FirebaseManager.shared.fetchTrips(for: userId) { result in
            switch result {
            case .success(let trips):
                self.trips = trips
            case .failure(let error):
                print("Error fetching trips: \(error.localizedDescription)")
                errorMessage = "Failed to load trips."
                showAlert = true
            }
            isLoading = false
        }
    }
    
    func deleteTrip(at offsets: IndexSet) {
        offsets.forEach { index in
            let trip = trips[index]
            if let tripID = trip.id {
                FirebaseManager.shared.deleteTrip(userId: userId, tripID: tripID) { result in
                    switch result {
                    case .success:
                        trips.remove(at: index)
                    case .failure(let error):
                        print("Error deleting trip: \(error.localizedDescription)")
                        errorMessage = "Failed to delete trip."
                        showAlert = true
                    }
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView(userId: "exampleUserId")
    }
}
