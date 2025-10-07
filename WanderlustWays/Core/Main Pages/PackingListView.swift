//
//  PackingListView.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PackingListView: View {
    var trip: Trip
    @State private var items: [PackingItem] = []
    @State private var categories: [String: [PackingItem]] = [:] // Dictionary to store items by category
    @State private var newItem = ""
    @State private var selectedCategory = "Clothing" // Default selected category
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var editingItem: PackingItem? = nil // Item being edited

    let categoryList = ["Clothing", "Toiletries", "Electronics", "Documents", "Other"] // List of categories

    var body: some View {
        VStack(spacing: 20) {
            // New Item Section with Category Selector
            HStack {
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categoryList, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                // New Item TextField and Add Button
                TextField("Enter new item", text: $newItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 10)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                Button(action: addItem) {
                    Text("Add")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()

            // Error Message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // Packing List with Categories and Checkboxes
            List {
                ForEach(categories.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category).font(.headline).foregroundColor(.blue)) {
                        ForEach(categories[category] ?? [], id: \.id) { item in
                            HStack {
                                // Checkbox
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? .green : .gray)
                                    .onTapGesture {
                                        toggleItemCheck(item)
                                    }
                                
                                Text(item.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Edit Button
                                Button(action: {
                                    editingItem = item
                                    newItem = item.name
                                    selectedCategory = item.category
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                
                                // Delete Button
                                Button(action: {
                                    deleteItem(item)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle("Packing List")
        .padding(.top)
        .onAppear(perform: fetchItems)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func addItem() {
        guard !newItem.isEmpty else { return }

        let item = PackingItem(name: newItem, category: selectedCategory, isChecked: false)
        
        if let editingItem = editingItem {
            // Update existing item
            FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("packingList").document(editingItem.id!).setData(item.dictionary) { error in
                if let error = error {
                    self.errorMessage = "Error updating item: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                fetchItems()
                self.newItem = "" // Clear the input field
                self.editingItem = nil // Clear the editing item
            }
        } else {
            // Add new item
            FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("packingList").addDocument(data: item.dictionary) { error in
                if let error = error {
                    self.errorMessage = "Error adding item: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                fetchItems()
                self.newItem = "" // Clear the input field
            }
        }
    }

    func fetchItems() {
        FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("packingList").getDocuments { (snapshot, error) in
            if let error = error {
                self.errorMessage = "Error fetching items: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            
            if let snapshot = snapshot {
                let fetchedItems = snapshot.documents.compactMap { document in
                    try? document.data(as: PackingItem.self)
                }
                
                // Group items by category
                self.categories = Dictionary(grouping: fetchedItems, by: { $0.category })
            }
        }
    }

    func toggleItemCheck(_ item: PackingItem) {
        // Toggle the item's checked state
        guard let itemId = item.id else { return }
        
        let updatedItem = PackingItem(name: item.name, category: item.category, isChecked: !item.isChecked)
        
        FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("packingList").document(itemId).setData(updatedItem.dictionary) { error in
            if let error = error {
                self.errorMessage = "Error updating item: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            fetchItems() // Refresh the list after updating the item
        }
    }

    func deleteItem(_ item: PackingItem) {
        guard let itemId = item.id else { return }
        
        FirebaseManager.shared.firestore.collection("users").document(trip.id!).collection("packingList").document(itemId).delete { error in
            if let error = error {
                self.errorMessage = "Error deleting item: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            fetchItems() // Refresh the list after deletion
        }
    }
}

struct PackingItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var category: String
    var isChecked: Bool // Added isChecked property
    
    var dictionary: [String: Any] {
        return ["name": name, "category": category, "isChecked": isChecked]
    }
}

struct PackingListView_Previews: PreviewProvider {
    static var previews: some View {
        PackingListView(trip: Trip(id: "1", destination: "Paris", startDate: Date(), endDate: Date(), transportType: "Plane"))
    }
}
