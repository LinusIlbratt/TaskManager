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
    @Published var isLoading: Bool = false
    
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
        
        isLoading = true
        
        db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                
                self.isLoading = false
                
                return
            }
            
            self.tasks = documents.compactMap { queryDocumentSnapshot -> Task? in
                return try? queryDocumentSnapshot.data(as: Task.self)
            }
            
            self.isLoading = false
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
                self?.isLoading = false
            }
            .store(in: &cancellables)
        
    }
    
    func fetchUserTasks() {
        isLoading = true
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
            
            let task = allTasksForThisUser[index]
            
            //Guard userId
            guard let userId = auth.currentUser?.uid else { return }
            
            //Update task in Firebase
            let taskUpdate = firebaseService.updateTaskInDatabase(taskId: taskId, isCompleted: isCompleted)
            
            //Update user's totalAmountOfFishesCollected based on task completion status
            let numberOfFishes = task.numberOfFishes
            
            //combine publishers
            let cancellable = taskUpdate
                .handleEvents(receiveOutput: { _ in
                   //Task update completed
                })
                .flatMap { _ -> AnyPublisher<Void, Never> in
                   //Proceeding to user update, include number of fishes
                    return self.updateUserFishesCollected(userId: userId, numberOfFishes: numberOfFishes, isCompleted: isCompleted)
                }
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Task and user update completed successfully.")
                    case .failure(let error):
                        print("Error updating task or user: \(error)")
                    }
                }, receiveValue: { _ in })
            
            //Store the cancellable
            self.cancellables.insert(cancellable)
        } else {
            print("Task not found")
        }
    }



    
    func updateUserFishesCollected(userId: String, numberOfFishes: Int, isCompleted: Bool) -> AnyPublisher<Void, Never> {
        return Future { promise in
            let userFetch = self.firebaseService.getUserById(userId: userId)
            
            userFetch
                .flatMap { user -> AnyPublisher<Void, Never> in
                    guard var user = user else {
                        return Just(()).eraseToAnyPublisher()
                    }
                    
                    // Update totalAmountOfFishesCollected based on completion status
                    if isCompleted {
                        user.totalAmountOfFishesCollected += numberOfFishes
                    } else {
                        user.totalAmountOfFishesCollected = max(0, user.totalAmountOfFishesCollected - numberOfFishes)
                    }
                    
                    // Perform the update for the user
                    return self.firebaseService.updateUserInDatabase(user: user).eraseToAnyPublisher()
                }
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("User update completed inside sink")
                        promise(.success(()))
                    case .failure(let error):
                        print("Error updating user: \(error)")
                        promise(.success(()))
                    }
                }, receiveValue: { _ in })
                .store(in: &self.cancellables) // Ensure to store the cancellable
        }
        .eraseToAnyPublisher()
    }




}

