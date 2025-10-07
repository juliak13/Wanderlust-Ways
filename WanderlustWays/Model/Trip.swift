//
//  Trip.swift
//  WanderlustWays
//
//  Created by Julia Konopka.
//

import Foundation
import FirebaseFirestore

struct Trip: Identifiable, Codable {
    @DocumentID var id: String?
    var destination: String
    var startDate: Date
    var endDate: Date
    var transportType: String
}
