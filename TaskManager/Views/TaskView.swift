//
//  TaskView.swift
//  TaskManager
//
//  Created by Mac on 2024-05-23.
//

import Foundation
import SwiftUI

struct TaskView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showingAddTaskView = false
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar()
                
                Text("Select task to schedule")
                    .font(.headline)
                    .padding()

                ScrollView {
                     ForEach(viewModel.tasks) { task in
                         HStack {
                             NavigationLink(destination: ScheduleTaskView(viewModel: viewModel, task: task)) {
                                 TaskCardListView(task: task, taskVM: viewModel)
                                     .padding(.horizontal)
                                     .padding(.top, 5)
                             }

                             Spacer()

                            //trash can to delete the task
                             Button(action: {
                                 viewModel.deleteTask(task: task)
                             }) {
                                 Image(systemName: "trash")
                                     .foregroundColor(.red)
                             }
                             .padding(.trailing)
                         }
                     }
                 }
                
                Spacer() // This will push the button to the bottom
                
                Button(action: {
                    showingAddTaskView = true
                }) {
                    Text("Create a new task")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40) // This will add fixed space below the button to avoid being hidden by TabView
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchTasks()
            }
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(viewModel: viewModel)
            }
        }
    }
}


struct TaskCardListView: View {
    var task: Task
    @ObservedObject var taskVM: TaskViewModel
    
    init(task: Task, taskVM: TaskViewModel) {
        self.task = task
        self.taskVM = taskVM
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                // Circle with the number of fishes available
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

                // Task details
                VStack(alignment: .leading) {
                    Text("Cleaning")
                        .font(.footnote)
                        .foregroundColor(.black)

                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        
                    // Print formatted due dates
                    if let dueDates = task.dueDates {
                        ForEach(dueDates, id: \.self) { date in
                            Text(formatDueDate(date: date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding()
        }
    }
    
    // Format date in this struct directly
    func formatDueDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return "Due \(formatter.string(from: date))"
    }
}




struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Task information")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                    .padding(.leading, 16)
                
                Group {
                    TextField("Name", text: $viewModel.title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                    
                    TextField("Add a description (optional)", text: $viewModel.description)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                    
                    /*TextField("Select category", text: $viewModel.assignedTo)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)*/
                    
                    Stepper("Select points (fishes): \(viewModel.numberOfFishes)", value: $viewModel.numberOfFishes, in: 0...100)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                    
                    //Choose if you want a notification
                    
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.addTask()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Create")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}
