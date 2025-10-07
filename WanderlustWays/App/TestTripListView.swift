//
//  TestTripListView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI

struct TestTripListView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var errorMessage = ""

    var userId: String

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading trips...")
            } else if trips.isEmpty {
                Text("No trips available.")
                    .foregroundColor(.gray)
            } else {
                List(trips) { trip in
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
        }
        .onAppear(perform: fetchTrips)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func fetchTrips() {
        print("DEBUG: Fetching trips for user ID: \(userId)")
        FirebaseManager.shared.firestore.collection("users").document(userId).collection("trips").getDocuments { (snapshot, error) in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to fetch trips: \(error.localizedDescription)"
                showAlert = true
                print("DEBUG: Error fetching trips: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                self.trips = snapshot.documents.compactMap { document in
                    try? document.data(as: Trip.self)
                }
                print("DEBUG: Fetched \(self.trips.count) trips.")
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

struct TestTripListView_Previews: PreviewProvider {
    static var previews: some View {
        TestTripListView(userId: "exampleUserId")
    }
}
