//
//  TaskListView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

import SwiftUI

//This view acts as start page in the app, shows calendar view + things to do today
struct TaskListView: View {
    
    //Get the data from our VM
    @StateObject private var taskVM = TaskViewModel()
    @State private var selectedDate: Date? = Date() // Initialize to today's date
    
    //Keep track of selected task in the list so we can show details of it
//    @State private var selectedTask: Task? = nil
    
    var body: some View {
        ZStack {
            VStack {
                // Include calendarView
                CalendarView(selectedDate: $selectedDate)
                
                Spacer()
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Today's tasks")
                        .padding(.top)
                        .padding(.leading)
                    
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
            //Lets show a popup with details of the task
            //ViewmModel makes sure selectedTask is update with latest state
            //CardView handles tap gesture for both card (detail view) and Done-button
            .blur(radius:  taskVM.selectedTask != nil ? 5 : 0)

            if let task =  taskVM.selectedTask {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                taskVM.selectedTask = nil
                            }
                        }

                    VStack {
                        Spacer()
                        TaskDetailView(task: task)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .transition(.move(edge: .bottom))
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            //Update ViewModel selectedDate to trigger filtering (when app launches)
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




