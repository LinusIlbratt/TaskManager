//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var dueDate: Date = Date()
    @Published var specificDate: Date = Date()
    @Published var isCompleted: Bool = false
    @Published var assignedTo: String = ""
    @Published var createdBy: String = ""
    @Published var familyId: String = ""
    @Published var taskColor: String = ""
    @Published var numberOfFishes: Int = 0
    
    private var db = Firestore.firestore()
    
    func fetchTasks() {
        db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.tasks = documents.compactMap { queryDocumentSnapshot -> Task? in
                return try? queryDocumentSnapshot.data(as: Task.self)
            }
        }
    }
    
    func addTask() {
        let newTask = Task(
            title: title,
            description: description,
            dueDate: dueDate,
            specificDate: specificDate,
            isCompleted: isCompleted,
            assignedTo: assignedTo,
            createdBy: createdBy,
            createdAt: Date(),
            familyId: familyId.isEmpty ? nil : familyId,
            taskColor: taskColor.isEmpty ? nil : taskColor,
            numberOfFishes: numberOfFishes
        )
        
        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
        } catch {
            print("Error adding task: \(error)")
        }
        
        title = ""
        description = ""
        dueDate = Date()
        specificDate = Date()
        isCompleted = false
        assignedTo = ""
        createdBy = ""
        familyId = ""
        taskColor = ""
        numberOfFishes = 0
    }
}

