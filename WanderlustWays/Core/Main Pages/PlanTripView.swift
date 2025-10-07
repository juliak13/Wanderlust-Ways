//
//  PlanTripView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//
import SwiftUI
import FirebaseFirestore

struct PlanTripView: View {
    var userId: String // This is passed to reference the user

    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var transportType = "Car" // Default transport type set to "Car"
    @State private var errorMessage = ""

    let transportTypes = ["Car", "Plane", "Boat", "Train"] // List of transport types

    var body: some View {
        Form {
            Section(header: Text("Plan it Yourself")) {
                TextField("Destination", text: $destination)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                
                // Transport Type Dropdown (Picker)
                Picker("Transport Type", selection: $transportType) {
                    ForEach(transportTypes, id: \.self) { transport in
                        Text(transport)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // You can use different picker styles, like .wheel or .segmented, depending on the design
                .padding()
            }

            Button(action: saveTrip) {
                Text("Save Trip")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Plan A Trip")
    }

    func saveTrip() {
        let tripData: [String: Any] = [
            "destination": destination,
            "startDate": startDate,
            "endDate": endDate,
            "transportType": transportType
        ]

        // Save the trip under the user's 'trips' subcollection
        FirebaseManager.shared.firestore.collection("users").document(userId).collection("trips").addDocument(data: tripData) { error in
            if let error = error {
                errorMessage = "Failed to save trip: \(error.localizedDescription)"
                return
            }
            errorMessage = "Trip Saved Successfully!"
        }
    }
}

struct PlanTripView_Previews: PreviewProvider {
    static var previews: some View {
        PlanTripView(userId: "exampleUserId")
    }
}
