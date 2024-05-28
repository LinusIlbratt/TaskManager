//
//  TaskListView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

//This view acts as start page in the app, shows calendar view + things to do today
struct TaskListView: View {
    
    //Get the data from our VM
    @StateObject private var taskVM = TaskViewModel()
    @State private var selectedDate: Date? = Date() // Initialize to today's date
    
    var body: some View {
        VStack {
            // Include calendarView
            CalendarView(selectedDate: $selectedDate)
            
            Spacer()
            Divider()
            
            VStack(alignment: .leading) {
                Text("Today's tasks")
                    .padding()
                
                // List of to-dos
                List {
                    ForEach(filteredTasks) { task in
                        // Card for each task
                        TaskCardView(task: task, taskVM: taskVM)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            // Update ViewModel selectedDate to trigger filtering (when app launches)
            taskVM.selectedDate = selectedDate
            taskVM.fetchUserTasks()
        }
    }
    
    // Filter task list based on selected date in calendar view
        var filteredTasks: [Task] {
            if let selectedDate = selectedDate {
                return taskVM.allTasksForThisUser.filter { task in
                    if let dueDates = task.dueDates {
                        return dueDates.contains { dueDate in
                            Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
                        }
                    }
                    return false
                }
            } else {
                return taskVM.allTasksForThisUser
            }
        }
    }


