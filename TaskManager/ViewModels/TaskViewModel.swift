//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import Foundation
import Combine
import FirebaseAuth


@MainActor //? Mainactor makes sure it runs on main thread?
class TaskViewModel: ObservableObject {
    
    let calendar = Calendar.current
    let today = Date()
    
    var auth = Auth.auth()
    
    var firestoreServices = FirestoreService()
    
    @Published var allTasksForThisUser: [Task] = []
    
    @Published var selectedDate: Date? {
            didSet {
                filterTasks()
            }
        }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        //First run and fetch tasks
        guard let user = auth.currentUser else {  return }
        firestoreServices.fetchTasks(assignedTo: user.uid)
        
        //thanks to combine, find these task to our array list
        bindTasks()
    }
    
    private func bindTasks() {
        firestoreServices.$userTasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.allTasksForThisUser = tasks
            }
            .store(in: &cancellables)
    }
    
    private func filterTasks() {
        if let selectedDate = selectedDate {
            allTasksForThisUser = firestoreServices.userTasks.filter { task in
                calendar.isDate(task.dueDate, inSameDayAs: selectedDate)
            }
        } else {
            allTasksForThisUser = firestoreServices.userTasks
        }
    }
    
    func updateTaskCompletion(taskId: String, isCompleted: Bool) {
        if let index = allTasksForThisUser.firstIndex(where: { $0.id == taskId }) {
            allTasksForThisUser[index].isCompleted = isCompleted
            
            //update in firebase
            firestoreServices.updateTaskInDatabase(taskId: taskId, isCompleted: isCompleted)
        }
    }
}
