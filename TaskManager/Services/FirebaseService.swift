//
//  FirebaseService.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FirebaseService: ObservableObject {
    @Published var selectedTask: Task?
    private var db = Firestore.firestore()
    
    @Published var tasks: [Task] = []
    
    func fetchTasks() {
        db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting tasks: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.tasks = documents.compactMap { document -> Task? in
                do {
                    return try document.data(as: Task.self)
                } catch {
                    print("Error decoding task: \(error)")
                    return nil
                }
            }
            
            print("Fetched \(self.tasks.count) tasks") // Debugging line
        }
    }
    
    func updateTaskDueDates(task: Task, dueDates: [Date]) {
        guard let taskId = task.id else {
            print("Task ID not found")
            return
        }
        
        db.collection("tasks").document(taskId).updateData(["dueDates": dueDates]) { error in
            if let error = error {
                print("Error updating task: \(error)")
            } else {
                print("Task dueDates updated successfully")
                if let index = self.tasks.firstIndex(where: { $0.id == taskId }) {
                    self.tasks[index].dueDates = dueDates
                }
            }
        }
    }
    
    func updateTaskWithDates(dates: [Date]) {
        selectedTask?.dueDates = dates
    }
}
