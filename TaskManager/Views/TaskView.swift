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
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select task to schedule")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    ForEach(viewModel.tasks) { task in
                        TaskCardView(task: task)
                            .padding(.horizontal)
                            .padding(.top, 5)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingAddTaskView = true
                }) {
                    Text("Create a new task")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Your Tasks")
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
                    
                    TextField("Select category", text: $viewModel.assignedTo)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                    
                    Stepper("Select points (fishes): \(viewModel.numberOfFishes)", value: $viewModel.numberOfFishes, in: 0...100)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .padding(.horizontal, 16)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.addTask()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Create")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(viewModel: TaskViewModel())
    }
}
