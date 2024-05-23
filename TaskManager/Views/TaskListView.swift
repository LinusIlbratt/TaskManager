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
                        TaskCardView(task: task)
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
        }
    }
    
    //Filter task list based on selected date in calendar view
    var filteredTasks: [Task] {
        if let selectedDate = selectedDate {
            return taskVM.allTasksForThisUser.filter { task in
                Calendar.current.isDate(task.dueDate, inSameDayAs: selectedDate)
            }
        } else {
            return taskVM.allTasksForThisUser
        }
    }
}




//Each TaskCard extracted as seperate views
struct TaskCardView: View {
    
    var task : Task
    
    var body: some View {
        HStack {
            //Circle with the number of fishes available
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 70, height: 70)
                        
                    VStack {
                        Text("\(task.numberOfFishes)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        Text("Fishes")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.bottom, 15)
                    }
                    .padding(20)
                    
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)

            //Task details
            VStack (alignment: .leading){
                Text("Cleaning")
                    .font(.footnote)

                Text(task.title)
                        .font(.headline)
                
                //Print formatted due date
                Text(formatDueDate(date: task.dueDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
               
                
                HStack {
                    Spacer()
                    // "Not Done" button
                    Button(action: {
                        // Action for the button
                    }) {
                        Text("Not Done")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    //Format date in this struct direct
    func formatDueDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return "Due \(formatter.string(from: date))"
    }
}
