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
        ZStack {
            VStack {
                //Include topbar
                TopBar()
                //Include filter
                FilterButtonView(selectedFilter: $taskVM.ourFilter)
                    .padding(.top)
                
                //Include calendarView
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
            .blur(radius: taskVM.selectedTask != nil ? 5 : 0)
            
            if let task = taskVM.selectedTask {
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
    
    //Filter task list based on selected date and filter in calendar view
    var filteredTasks: [Task] {
        let tasksForSelectedDate = taskVM.allTasksForThisUser.filter { task in
            if let dueDates = task.dueDates {
                return dueDates.contains { dueDate in
                    Calendar.current.isDate(dueDate, inSameDayAs: selectedDate ?? Date())
                }
            }
            return false
        }
        //Continue to filter based on isCompleted
        switch taskVM.ourFilter {
        case .upcoming:
            return tasksForSelectedDate.filter { !$0.isCompleted }
        case .completed:
            return tasksForSelectedDate.filter { $0.isCompleted }
        }
    }
}



enum TaskFilter {
    case upcoming
    case completed
}

struct FilterButtonView: View {
    @Binding var selectedFilter: TaskFilter
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                selectedFilter = .upcoming
            }) {
                Text("Upcoming")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(selectedFilter == .upcoming ? Color.gray : Color(UIColor.systemGray4))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                selectedFilter = .completed
            }) {
                Text("Completed")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(selectedFilter == .completed ? Color.gray : Color(UIColor.systemGray4))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
    }
}


