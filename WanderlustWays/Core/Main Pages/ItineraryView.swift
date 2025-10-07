//
//  ItineraryView.swift
//  Wanderlust Ways
//
//  Created by Julia Konopka.
//


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift


//MARK: itinerary view

struct ItineraryView: View {
    var trip: Trip
    @State private var itinerary: [ItineraryItem] = []
    @State private var selectedDate = Date()
    @State private var newActivity = ""
    @State private var newStartTime = Date()
    @State private var newEndTime = Date()
    @State private var isReservation = false
    @State private var reservationType = "Dinner"
    @State private var showAddActivitySheet = false
    @State private var editingItem: ItineraryItem?

    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            HStack {
                Spacer()
                Button(action: { showAddActivitySheet.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding()
                }
            }

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(itinerary.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.startTime, style: .time)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(width: 80, alignment: .leading)
                                Text(item.endTime, style: .time)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(width: 80, alignment: .leading)
                            }
                            .frame(width: 60, alignment: .leading)
                            VStack(alignment: .leading) {
                                Text(item.activity)
                                    .font(.headline)
                                if item.isReservation {
                                    Text(item.reservationType)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            Button(action: { editActivity(item) }) {
                                Image(systemName: "pencil")
                            }
                            .padding(.trailing, 10)
                            Button(action: { deleteActivity(item) }) {
                                Image(systemName: "trash")
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Itinerary")
        .onAppear(perform: fetchItinerary)
        .sheet(isPresented: $showAddActivitySheet) {
            AddActivityView(
                newActivity: $newActivity,
                newStartTime: $newStartTime,
                newEndTime: $newEndTime,
                isReservation: $isReservation,
                reservationType: $reservationType,
                addActivity: addActivity,
                editingItem: $editingItem
            )
        }
    }

    func addActivity() {
        let item = ItineraryItem(
            activity: newActivity,
            date: selectedDate,
            startTime: newStartTime,
            endTime: newEndTime,
            isReservation: isReservation,
            reservationType: reservationType
        )
        
        if let editingItem = editingItem {
            FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("itinerary").document(editingItem.id!).setData(item.dictionary) { error in
                if let error = error {
                    print("Error updating activity: \(error.localizedDescription)")
                    return
                }
                print("Activity updated successfully")
                fetchItinerary()
            }
        } else {
            FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("itinerary").addDocument(data: item.dictionary) { error in
                if let error = error {
                    print("Error adding activity: \(error.localizedDescription)")
                    return
                }
                print("Activity added successfully")
                fetchItinerary()
            }
        }
        
        newActivity = ""
        newStartTime = Date()
        newEndTime = Date()
        isReservation = false
        reservationType = "Dinner"
        editingItem = nil
        showAddActivitySheet = false
    }

    func fetchItinerary() {
        FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("itinerary").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching itinerary: \(error.localizedDescription)")
                return
            }
                
            if let snapshot = snapshot {
                self.itinerary = snapshot.documents.compactMap { document in
                    try? document.data(as: ItineraryItem.self)
                }
                print("Itinerary fetched: \(self.itinerary)")
            }
        }
    }

    func deleteActivity(_ item: ItineraryItem) {
        if let id = item.id {
            FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("itinerary").document(id).delete { error in
                if let error = error {
                    print("Error deleting activity: \(error.localizedDescription)")
                    return
                }
                print("Activity deleted successfully")
                fetchItinerary()
            }
        }
    }

    func editActivity(_ item: ItineraryItem) {
        newActivity = item.activity
        newStartTime = item.startTime
        newEndTime = item.endTime
        isReservation = item.isReservation
        reservationType = item.reservationType
        editingItem = item
        showAddActivitySheet = true
    }
}
//MARK: add activity
struct AddActivityView: View {
    @Binding var newActivity: String
    @Binding var newStartTime: Date
    @Binding var newEndTime: Date
    @Binding var isReservation: Bool
    @Binding var reservationType: String
    var addActivity: () -> Void
    @Binding var editingItem: ItineraryItem?

    var body: some View {
        NavigationView {
            Form {
                TextField("Activity", text: $newActivity)
                DatePicker("Start Time", selection: $newStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End Time", selection: $newEndTime, displayedComponents: .hourAndMinute)
                Toggle("Is Reservation", isOn: $isReservation)
                if isReservation {
                    Picker("Reservation Type", selection: $reservationType) {
                        Text("Dinner").tag("Dinner")
                        Text("Ticket").tag("Ticket")
                        Text("Other").tag("Other")
                    }
                }
            }
            .navigationTitle(editingItem == nil ? "Add Activity" : "Edit Activity")
            .navigationBarItems(trailing: Button("Save") {
                addActivity()
            })
        }
    }
}

//itinerary items
struct ItineraryItem: Identifiable, Codable {
    @DocumentID var id: String?
    var activity: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var isReservation: Bool
    var reservationType: String
        
    var dictionary: [String: Any] {
        return [
            "activity": activity,
            "date": date,
            "startTime": startTime,
            "endTime": endTime,
            "isReservation": isReservation,
            "reservationType": reservationType
        ]
    }
}

//preview
struct ItineraryView_Previews: PreviewProvider {
    static var previews: some View {
        ItineraryView(trip: Trip(destination: "Paris", startDate: Date(), endDate: Date(), transportType: "Plane"))
    }
}
