//
//  Group.swift
//  TaskManager
//
//  Created by Andreas Selguson on 2024-05-30.
//

import Foundation
import FirebaseFirestoreSwift

struct Groups: Identifiable, Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var description: String?
}
