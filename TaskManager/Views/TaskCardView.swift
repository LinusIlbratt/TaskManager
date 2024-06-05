//
//  TaskCardView.swift
//  TaskManager
//
//  Created by Mattias Axelsson on 2024-05-28.
//

import SwiftUI

//Each TaskCard extracted as separate views
struct TaskCardView: View {
    
    var task : Task
    @ObservedObject var taskVM: TaskViewModel
    
    @State private var isCompleted: Bool
    @Binding var startPosition: CGPoint
    var onTaskCompleted: () -> Void // Callback to notify when task is completed
    @Binding var selectedDate: Date?
    
    init(task: Task, taskVM: TaskViewModel, startPosition: Binding<CGPoint>, onTaskCompleted: @escaping () -> Void, selectedDate: Binding<Date?>) {
        self.task = task
        self.taskVM = taskVM
        self._isCompleted = State(initialValue: task.isCompleted)
        self._startPosition = startPosition
        self.onTaskCompleted = onTaskCompleted
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                //Circle with the number of fishes available
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 70, height: 70)
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            DispatchQueue.main.async {
                                                let position = CGPoint(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
                                                self.startPosition = position
                                            }
                                        }
                                }
                            )
                        
                        
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
                        .padding(10)
                        
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                
                // Task details
                VStack(alignment: .leading) {
                    Text("Cleaning")
                        .font(.footnote)
                        .padding(.top, 10)
                    
                    Text(task.title)
                        .font(.headline)
                    
                    Spacer()
                }
                
                
                Spacer()
            }
            .contentShape(Rectangle()) //Make the entire HStack tappable
            .onTapGesture {
                //Handle tap on the whole card here if needed
                withAnimation {
                    taskVM.selectedTask = task
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.bottom)
            
            // "Not Done" button
            Button(action: {
                onTaskCompleted()
                withAnimation {
                    toggleTaskCompletion()
                }
            }) {
                Text(isCompleted ? "Done" : "Mark as Done")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(isCompleted ? Color.gray.opacity(0.8) : Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(isCompleted ? .white : .primary)
            }
            .padding([.trailing, .bottom], 20)
            .background(Color.clear) //Ensure the button has a tappable area
            .zIndex(1) // Ensure button is on top
            .padding(10)
            
            
        }
    }
    
    //Format date in this struct directly
    func formatDueDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return "Due \(formatter.string(from: date))"
    }
    
    //Toggle task completion status and update in ViewModel
    private func toggleTaskCompletion() {
        
        //We eiter use current day which is most correct?
//        let today = Calendar.current.startOfDay(for: Date())
        //But selected date will help remove the task from the list in the future when displayed..
        guard let selectedDate = selectedDate else { return }
        
        if let taskId = task.id {
            let isTaskCompletedOnSelectedDate = task.completedDates?.contains { Calendar.current.isDate($0, inSameDayAs: selectedDate) } ?? false
            
            taskVM.updateTaskCompletion(taskId: taskId, for: selectedDate, isCompleted: !isTaskCompletedOnSelectedDate)
            onTaskCompleted()
        }
    }
}
