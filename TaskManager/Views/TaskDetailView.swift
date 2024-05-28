//
//  TaskDetailView.swift
//  TaskManager
//
//  Created by Mattias Axelsson on 2024-05-28.
//

import SwiftUI

struct TaskDetailView: View {
    var task: Task

    var body: some View {
        VStack {
            Text("Task Details")
                .font(.title)
                .padding()

            VStack(alignment: .leading) {
                Text("Category")
                    .font(.headline)
                Text(task.title)
                    .font(.largeTitle)
                    .bold()
                Text(task.description)
                    .font(.body)
                    .padding(.top)

                Text("\(task.numberOfFishes) Fishes")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                if task.isCompleted {
                    Text("Task is complete")
                        .foregroundColor(.green)
                } else {
                    Text("Task is incomplete")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            .padding()
        }
    }
}

