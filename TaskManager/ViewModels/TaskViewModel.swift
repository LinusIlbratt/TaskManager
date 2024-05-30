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
import FirebaseAuth

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
    
    var auth = Auth.auth()
    private var db = Firestore.firestore()
    private var firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedDate: Date? {
        didSet {
            filterTasks()
        }
    }
    
    @Published var selectedTask: Task?
    
    @Published var ourFilter: TaskFilter = .upcoming
    
    init() {
        // First run and fetch tasks
        guard let user = auth.currentUser else { return }
        firebaseService.fetchTasks(assignedTo: user.uid)
        
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
    
    func updateTaskDueDates(task: Task, dueDates: [Date]) {
        firebaseService.updateTaskDueDates(task: task, dueDates: dueDates)
    }
    
    func updateTaskAssignedTo(task: Task, assignedTo: [String]) {
            firebaseService.updateTaskAssignedTo(task: task, assignedTo: assignedTo)
        }
    
    private func bindTasks() {
        firebaseService.$userTasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.allTasksForThisUser = tasks
            }
            .store(in: &cancellables)
    }
    
    func fetchUserTasks() {
            guard let user = auth.currentUser else { return }
            firebaseService.fetchTasks(assignedTo: user.uid)
        }
    
    private func filterTasks() {
        if let selectedDate = selectedDate {
            allTasksForThisUser = firebaseService.userTasks.filter { task in
                if let dueDate = task.dueDates?.first {
                    return calendar.isDate(dueDate, inSameDayAs: selectedDate)
                }
                return false
            }
        } else {
            allTasksForThisUser = firebaseService.userTasks
        }
    }

    
    func updateTaskCompletion(taskId: String, isCompleted: Bool) {
        if let index = allTasksForThisUser.firstIndex(where: { $0.id == taskId }) {
            allTasksForThisUser[index].isCompleted = isCompleted
            
            // Update in firebase
            firebaseService.updateTaskInDatabase(taskId: taskId, isCompleted: isCompleted)
        }
    }
}

