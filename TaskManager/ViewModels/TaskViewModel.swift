//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var allTasksForThisUser: [Task] = []
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
    
    let calendar = Calendar.current
    let today = Date()
    
    private var db = Firestore.firestore()
    private var firestoreServices = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // First run and fetch tasks
        fetchTasks()
        firestoreServices.fetchTasks()
        
        // Thanks to Combine, bind these tasks to our array list
        bindTasks()
    }
    
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
            specificDate: specificDate,
            isCompleted: isCompleted,
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
        specificDate = Date()
        isCompleted = false
        createdBy = ""
        familyId = ""
        taskColor = ""
        numberOfFishes = 0
    }
    
    private func bindTasks() {
        firestoreServices.$tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.allTasksForThisUser = tasks
            }
            .store(in: &cancellables)
    }
}
