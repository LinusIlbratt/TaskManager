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
    
    // New list for userTasks
    @Published var userTasks: [Task] = []
    
    @Published var users: [User] = []
    
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
    
    func fetchUsers() {
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    self.users = querySnapshot.documents.compactMap { document -> User? in
                        let data = document.data()
                        print("Fetched user data: \(data)") // Debugging line
                        return try? document.data(as: User.self)
                    }
                    print("Users count: \(self.users.count)") // Debugging line
                }
            }
        }
    }
    
    // Function to fetch tasks assigned to a specific user
    func fetchTasks(assignedTo userId: String) {
        db.collection("tasks")
            .whereField("assignedTo", arrayContains: userId)
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting tasks: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.userTasks = documents.compactMap { document -> Task? in
                    do {
                        return try document.data(as: Task.self)
                    } catch {
                        print("Error decoding task: \(error)")
                        return nil
                    }
                }
                
                print("Fetched \(self.userTasks.count) tasks assigned to \(userId)") // Debugging line
            }
    }
    
    
    // Function to update task completion status
    func updateTaskInDatabase(taskId: String, isCompleted: Bool) -> Future<Void, Never> {
        print("Starting updateTaskInDatabase with taskId: \(taskId) and isCompleted: \(isCompleted)")
        return Future { promise in
            let taskRef = self.db.collection("tasks").document(taskId)
            
            taskRef.updateData(["isCompleted": isCompleted]) { error in
                if let error = error {
                    print("Error updating task: \(error)")
                } else {
                    print("Task updated successfully in updateTaskInDatabase")
                }
                promise(.success(()))
            }
        }
    }

    func updateTaskAssignedTo(task: Task, assignedTo: [String]) {
        guard let taskId = task.id else {
            print("Task ID not found")
            return
        }
        
        db.collection("tasks").document(taskId).updateData(["assignedTo": assignedTo]) { error in
            if let error = error {
                print("Error updating task: \(error)")
            } else {
                print("Task assignedTo updated successfully")
            }
        }
    }
    
    // Function to update task due dates
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
    
    // Function to update selected task with dates
    func updateTaskWithDates(dates: [Date]) {
        selectedTask?.dueDates = dates
    }
    
    func getUserById(userId: String) -> Future<User?, Never> {
            return Future { promise in
                let userRef = self.db.collection("users").document(userId)
                
                userRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        do {
                            let user = try document.data(as: User.self)
                            promise(.success(user))
                        } catch {
                            print("Error decoding user: \(error)")
                            promise(.success(nil))
                        }
                    } else {
                        print("User does not exist")
                        promise(.success(nil))
                    }
                }
            }
        }
        
        func updateUserInDatabase(user: User) -> Future<Void, Never> {
            return Future { promise in
                guard let userId = user.id else {
                    print("User ID is nil")
                    promise(.success(()))
                    return
                }
                
                let userRef = self.db.collection("users").document(userId)
                
                do {
                    try userRef.setData(from: user) { error in
                        if let error = error {
                            print("Error updating user: \(error)")
                        }
                        promise(.success(()))
                    }
                } catch {
                    print("Error updating user: \(error)")
                    promise(.success(()))
                }
            }
        }

}
