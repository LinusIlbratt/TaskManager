//
//  ScheduleTaskView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-22.
//

import SwiftUI

struct ScheduleTaskView: View {
    @State private var currentDate = Date()
    
    private var calendar: Calendar {
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            return calendar
        }
        
        private var daysInMonth: [Date] {
            guard let range = calendar.range(of: .day, in: .month, for: currentDate) else {
                return []
            }
            return range.compactMap { day -> Date? in
                var components = calendar.dateComponents([.year, .month], from: currentDate)
                components.day = day
                return calendar.date(from: components)
            }
        }
        
        private var firstWeekday: Int {
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            guard let firstOfMonth = calendar.date(from: components) else {
                return 0
            }
            let weekday = calendar.component(.weekday, from: firstOfMonth)
            return (weekday + 5) % 7
        }

    
    var body: some View {
        ZStack {
            // Background color
            Color(.systemGray5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Schedule Task")
                    .font(.headline)
                    .padding()

                // Task information
                TaskInfoView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        }
                    )
                    .padding(.horizontal, 40)

                // Calendar
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .padding()
                        }
                        
                        Spacer()
                        
                        Text("\(monthYearFormatter.string(from: currentDate))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .padding()
                        }
                    }
                    
                    HStack {
                        ForEach(["M", "T", "O", "T", "F", "L", "S"], id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .font(.caption)
                        }
                    }
                    
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<firstWeekday, id: \.self) { _ in
                            Text("")
                                .frame(maxWidth: .infinity)
                        }
                        
                        ForEach(daysInMonth, id: \.self) { date in
                            Text("\(calendar.component(.day, from: date))")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(
                                    calendar.isDate(date, inSameDayAs: Date()) ? Color.blue : Color.clear
                                )
                                .cornerRadius(8)
                                .foregroundColor(calendar.isDate(date, inSameDayAs: Date()) ? .white : .black)
                                .frame(width: 55, height: 40)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 5)
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
                            .frame(maxHeight: 30)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 35)
            }
            .padding(.vertical)
        }
    }

    private let monthYearFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "MMMM yyyy"
           return formatter
       }()

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
