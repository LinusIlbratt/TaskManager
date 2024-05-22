//
//  ScheduleTaskView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-22.
//

import SwiftUI

struct ScheduleTaskView: View {
    @State private var currentDate = Date()
    
    
    
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Schedule Task")
                    .font(.headline)
                    .padding()

                // Task information
                TaskInfoView()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)

                

                // Buttons
                VStack(spacing: 10) {
                    Button(action: {}) {
                        Text("Set Alarm")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 10)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }

                    Button(action: {}) {
                        Text("Assign family member")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 10)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    Spacer()

                    Button(action: {}) {
                        Text("Schedule Task")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 35)
            }
            .padding(.vertical)
        }
    }

   
}

struct TaskInfoView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack {
                Spacer()
                Circle()
                    .fill(Color.black)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("20")
                            .foregroundColor(.white)
                            .font(.title)
                    )
                Spacer()
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Cleaning")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("Clean your bedroom")
                    .font(.headline)
            }
            .padding(.leading, 10)

            Spacer()
        }
        .padding()
    }
}

struct ScheduleTaskView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleTaskView()
    }
}
