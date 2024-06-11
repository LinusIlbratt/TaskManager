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
                
                //task details
                VStack(alignment: .leading) {
                    Text("Cleaning")
                        .font(.footnote)
                        .padding(.top, 10)
                    
                    Text(task.title)
                        .font(.headline)
                    
                    //circles with first letter of display names
                    VStack {
                        if taskVM.users.isEmpty && taskVM.errorMessage == nil {
                            Text("Loading users...")
                        } else if let errorMessage = taskVM.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            HStack {
                                ForEach(taskVM.users) { user in
                                    ZStack {
                                        if let color = user.userColor {
                                            Circle()
                                                .fill(Color(hex: color))
                                                .frame(width: 25, height: 25)
                                        } else {
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 25, height: 25)
                                        }
                                        Text(String(user.displayName.prefix(1)))
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .onAppear {
                        //guard assignedTo if its empty
                        guard let assignedTo = task.assignedTo else { return }
                        
                        taskVM.fetchUsersFromDatabase(with: assignedTo)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .contentShape(Rectangle()) //Make the entire HStack tappable
            .onTapGesture {
                //on tap on whole card
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
            
            //"Done" button
            Button(action: {
                onTaskCompleted()
                withAnimation {
                    toggleTaskCompletion()
                }
            }) {
                Text(isCompletedForSelectedDate() ? "Mark as not done" : "Mark as Done")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(isCompletedForSelectedDate() ? Color.gray.opacity(0.8) : Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(isCompletedForSelectedDate() ? .white : .primary)
            }
            .padding([.trailing, .bottom], 15)
            .background(Color.clear) // Ensure the button has a tappable area
            .zIndex(1) // Ensure button is on top
            .padding(10)
        }
    }
    //Check if the task is completed for the selected date
    private func isCompletedForSelectedDate() -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return task.completedDates?.contains(where: { Calendar.current.isDate($0, inSameDayAs: selectedDate) }) ?? false
    }
    
    //Format date in this struct directly
    func formatDueDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return "Due \(formatter.string(from: date))"
    }
    
    //toggle task completion status and update in ViewModel
    private func toggleTaskCompletion() {
        
        //We eiter use current day which is most correct?
        // let today = Calendar.current.startOfDay(for: Date())
        //But selected date will help remove the task from the list in the future when displayed..
        guard let selectedDate = selectedDate else { return }
        
        if let taskId = task.id {
            let isTaskCompletedOnSelectedDate = task.completedDates?.contains { Calendar.current.isDate($0, inSameDayAs: selectedDate) } ?? false
            
            taskVM.updateTaskCompletion(taskId: taskId, for: selectedDate, isCompleted: !isTaskCompletedOnSelectedDate)
            onTaskCompleted()
        }
    }
}
