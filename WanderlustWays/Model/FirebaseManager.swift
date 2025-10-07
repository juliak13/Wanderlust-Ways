//
//  FirebaseManager.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    var auth: Auth
    var firestore: Firestore
    
    private init() {
        auth = Auth.auth()
        firestore = Firestore.firestore()
    }
    
    func fetchTrips(for userId: String, completion: @escaping (Result<[Trip], Error>) -> Void) {
        firestore.collection("users")
            .document(userId)
            .collection("trips")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let trips = snapshot.documents.compactMap { document in
                        try? document.data(as: Trip.self)
                    }
                    completion(.success(trips))
                }
            }
    }
    
    func deleteTrip(userId: String, tripID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.collection("users")
            .document(userId)
            .collection("trips")
            .document(tripID)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
