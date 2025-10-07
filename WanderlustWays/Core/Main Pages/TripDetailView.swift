//
//  TripDetailView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI

struct TripDetailView: View {
    var trip: Trip
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title Section
                Text(trip.destination)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding([.top, .horizontal])
                
                // Trip Details Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("\(trip.startDate, formatter: dateFormatter) - \(trip.endDate, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "airplane")
                            .foregroundColor(.green)
                        Text(trip.transportType)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons Section
                VStack(spacing: 20) {
                    NavigationLink(destination: PackingListView(trip: trip)) {
                        Text("View Packing List")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ItineraryView(trip: trip)) {
                        Text("View Itinerary")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("Delete Trip")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Delete Trip"),
                            message: Text("Are you sure you want to delete this trip?"),
                            primaryButton: .destructive(Text("Delete")) {
                                // Handle the delete action here
                                deleteTrip(trip)
                                presentationMode.wrappedValue.dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteTrip(_ trip: Trip) {
        // Implement the delete logic here
        print("Trip deleted: \(trip.destination)")
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView(trip: Trip(destination: "Paris", startDate: Date(), endDate: Date(), transportType: "Plane"))
    }
}
