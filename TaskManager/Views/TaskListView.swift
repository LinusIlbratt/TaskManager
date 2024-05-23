//
//  TaskListView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-15.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

//Each TaskCard extracted as separate views
struct TaskCardView: View {
    
    var task : Task
    @ObservedObject var taskVM: TaskViewModel
    @State private var isCompleted: Bool
    
    init(task: Task, taskVM: TaskViewModel) {
        self.task = task
        self.taskVM = taskVM
        self._isCompleted = State(initialValue: task.isCompleted)
    }
    
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
            VStack (alignment: .leading) {
                Text("Cleaning")
                    .font(.footnote)

                Text(task.title)
                    .font(.headline)
                
                // Print formatted due dates
                if let dueDates = task.dueDates {
                    ForEach(dueDates, id: \.self) { date in
                        Text(formatDueDate(date: date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Spacer()
                    // "Not Done" button
                    Button(action: {
                        toggleTaskCompletion()
                    }) {
                        Text(isCompleted ? "Done" : "Not Done")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(isCompleted ? Color.gray.opacity(0.8) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(isCompleted ? .white : .primary)
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
    
    // Format date in this struct directly
    func formatDueDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return "Due \(formatter.string(from: date))"
    }
    
    // Toggle task completion status and update in ViewModel
    private func toggleTaskCompletion() {
        if let taskId = task.id {
            isCompleted.toggle()
            taskVM.updateTaskCompletion(taskId: taskId, isCompleted: isCompleted)
        }
    }
}
