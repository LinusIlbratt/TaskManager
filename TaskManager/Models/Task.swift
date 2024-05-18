//
//  Task.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import Foundation
import FirebaseFirestoreSwift

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var dueDate: Date
    var isCompleted: Bool
    var assignedTo: String
    var createdBy: String
    var createdAt: Date
    var familyId: String?
    var taskColor: String?
}
