//
//  User.swift
//  TaskManager
//
//  Created by Andreas Selguson on 2024-05-25.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var assignedTasks: [String]?
}
