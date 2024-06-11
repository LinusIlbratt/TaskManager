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
    
    @State private var startPosition: CGPoint = .zero
    @State private var endPosition: CGPoint = .zero
    @State private var showFish = false
    @State private var fishCount = 0
    @State private var animationTrigger = false
    
    //create a DateFormatter
    //perhaps move this to dateformatter class?
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    var body: some View {
        ZStack {
            
            VStack {
                //Include topbar
                TopBar()
                
                //Include scrollview to allow scroll everything (especially important in landscape mode)
                ScrollView {
                    //Include filter
                    FilterButtonView(selectedFilter: $taskVM.ourFilter)
                        .padding(.top)
                    
                    
                    // Check if tasks are loaded
                    if taskVM.isLoading {
                        ProgressView("Loading tasks...")
                            .padding()
                    } else {
                        //Include calendarView
                        CalendarView(selectedDate: $selectedDate, taskListAvailable: $taskVM.allTasksForThisUser)
                        
                        Spacer()
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Tasks for \(selectedDate.map { dateFormatter.string(from: $0) } ?? "selected date")")
                                .padding(.top)
                                .padding(.leading)
                            
                            //List of to-dos
                            ScrollView {
                                //LazyVStack instead of List to allow for scrollview
                                LazyVStack {
                                    ForEach(filteredTasks) { task in
                                        // Card for each task
                                        TaskCardView(
                                            task: task,
                                            taskVM: taskVM,
                                            startPosition: $startPosition,
                                            onTaskCompleted: {
                                                //show animation only on upcoming tasks
                                                    if taskVM.ourFilter == .upcoming {
                                                        self.fishCount = task.numberOfFishes
                                                        self.showFish = true
                                                        withAnimation {
                                                            self.animationTrigger = true
                                                        }
                                                    }
                                                },
                                            selectedDate: $selectedDate
                                        )
                                        .padding(.vertical, 5)
                                        .background(Color.clear)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
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
                        TaskDetailView(task: task, selectedDate: $selectedDate)
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
            if showFish {
                ForEach(0..<fishCount, id: \.self) { index in
                    FishAnimationView(animationTrigger: $animationTrigger, startPosition: startPosition, endPosition: endPosition)
                        .position(startPosition)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1).delay(Double.random(in: 0...0.5))) {
                                self.animationTrigger = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                self.showFish = false
                                self.animationTrigger = false // Reset animation trigger
                            }
                        }
                }
            }
        }
        .onAppear {
            //Update ViewModel selectedDate to trigger filtering (when app launches)
            taskVM.fetchUserTasks()
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        DispatchQueue.main.async {
                            // Set end position to the bottom right corner
                            let screenBounds = UIScreen.main.bounds
                            self.endPosition = CGPoint(x: screenBounds.maxX - 10, y: screenBounds.maxY - 30)
                        }
                    }
            }
        )
        
    }
    
    //Filter task list based on selected date and filter in calendar view
    var filteredTasks: [Task] {
        guard let selectedDate = selectedDate else {
            
            //no date is selcted for some reason..
            return []
        }

        //filter on selected date
        let tasksForSelectedDate = taskVM.allTasksForThisUser.filter { task in
            if let dueDates = task.dueDates {
                return dueDates.contains { dueDate in
                    Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
                }
            }
            return false
        }
        
        //continue filter based on completed status (completedDates) and selected date
        switch taskVM.ourFilter {
            
        //case upcoming
        case .upcoming:
            let upcomingTasks = tasksForSelectedDate.filter { task in
                !(task.completedDates?.contains { completedDate in
                    Calendar.current.isDate(completedDate, inSameDayAs: selectedDate)
                } ?? false)
            }
            return upcomingTasks
            
        //case completed
        case .completed:
            let completedTasks = tasksForSelectedDate.filter { task in
                task.completedDates?.contains { completedDate in
                    Calendar.current.isDate(completedDate, inSameDayAs: selectedDate)
                } ?? false
            }
            return completedTasks
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


