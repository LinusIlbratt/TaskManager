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
    
    var listOfTasks = [Task]()
    
    init() {
        
        //Mockup data until firebase is up an running
        listOfTasks = [
            Task(
                id: UUID().uuidString,
                title: "Clean your bedroom",
                description: "Tidy up the room, dust surfaces, and vacuum the floor.",
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                isCompleted: false,
                assignedTo: "John Doe",
                createdBy: "Jane Doe",
                createdAt: Date(),
                familyId: "Family123",
                taskColor: "Blue"
            ),
            Task(
                id: UUID().uuidString,
                title: "Grocery shopping",
                description: "Buy groceries for the week including vegetables, fruits, and dairy products.",
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                isCompleted: false,
                assignedTo: "Mary Johnson",
                createdBy: "Jane Doe",
                createdAt: Date(),
                familyId: "Family123",
                taskColor: "Green"
            ),
            Task(
                id: UUID().uuidString,
                title: "Car maintenance",
                description: "Take the car for an oil change and tire rotation.",
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                isCompleted: false,
                assignedTo: "John Doe",
                createdBy: "Jane Doe",
                createdAt: Date(),
                familyId: "Family123",
                taskColor: "Red"
            )
        ]
    }
    
    var body: some View {
        
            CalendarView()
        
        
        Spacer()
        Divider()
        
        VStack(alignment: .leading) {
            Text("Todays tasks")
                .padding()
            
            //List of to-dos
            List {
                ForEach (listOfTasks) { task in
                    
                    TaskCardView(task: task)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                                
                }
            }
            .listStyle(PlainListStyle())
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
                        Text("20")
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
                
                Text("Due 05/14/24")
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
}
