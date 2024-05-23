//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import Foundation
import Combine


@MainActor //? Mainactor makes sure it runs on main thread?
class TaskViewModel: ObservableObject {
    
    let calendar = Calendar.current
    let today = Date()
    
    var firestoreServices = FirestoreService()
    
    @Published var allTasksForThisUser: [Task] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        //First run and fetch tasks
        firestoreServices.fetchTasks()
        
        //thanks to combine, find these task to our array list
        bindTasks()
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
