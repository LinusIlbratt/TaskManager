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
            VStack(spacing: 20) {
                HStack {
                    Text("Task Details")
                        .font(.headline)
                        .padding(.top)
                    Spacer()
                }
                    
                VStack(alignment: .leading, spacing: 10) {
                    Text("Category")
                        .font(.caption)
                        .padding(.bottom, 5)
                        .foregroundColor(.gray)
                    
                    Text(task.title)
                        .font(.headline)
                        .bold()
                    
                    Text(task.description)
                        .font(.subheadline)
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.5))
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    }
                )
                .padding(.horizontal)
                
                VStack {
                    
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(task.numberOfFishes)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Fishes")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                        }
                        .frame(width: 100, height: 100)
                        .background(Circle().fill(Color.black))
                        .padding(.vertical, 10)
                        
                        Spacer()
                    }
                }
                
                
                Text(task.isCompleted ? "Task is complete" : "Task is incomplete")
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? .green : .red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.black, lineWidth: 1)
                        }
                    )
            }
        }
        .padding()
    }
}
