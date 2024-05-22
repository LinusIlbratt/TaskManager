//
//  ScheduleTaskView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-22.
//

import SwiftUI

struct ScheduleTaskView: View {
    @State private var currentDate = Date()
    @State private var selectedDates: Set<Date> = []
    
    var body: some View {
        ZStack {
            // Background color
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                HStack {
                    Text("Schedule Task")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)

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
                                self.decrementMonth()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .padding()
                        }
                        
                        Spacer()
                        
                        Text("\(self.monthYearString(from: currentDate))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.incrementMonth()
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
                        ForEach(0..<self.firstWeekday(), id: \.self) { _ in
                            Text("")
                                .frame(maxWidth: .infinity)
                        }
                        
                        ForEach(self.daysInMonth(), id: \.self) { date in
                            ZStack {
                                if selectedDates.contains(date) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.clear)
                                }

                                if self.isCurrentDate(date) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 2)
                                }

                                Text("\(self.dayString(from: date))")
                                    .foregroundColor(
                                        selectedDates.contains(date) ? .white :
                                        self.isCurrentDate(date) ? .black :
                                        (date < Date() ? .gray : .black)
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(4)
                                    .background(Color.clear)
                                    .onTapGesture {
                                        if date >= Calendar.current.startOfDay(for: Date()) {
                                            if selectedDates.contains(date) {
                                                selectedDates.remove(date)
                                            } else {
                                                selectedDates.insert(date)
                                            }
                                        }
                                    }
                                    .layoutPriority(1)
                            }

                            .frame(minWidth: 40, maxWidth: .infinity, minHeight: 40, maxHeight: 40)
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
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 5)
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white .opacity(0.5))
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                }
                            )
                    }
                    
                    Button(action: {}) {
                        Text("Assign family member")
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 5)
                            .padding()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white .opacity(0.5))
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                }
                            )
                    }
                    
                    Spacer()

                    Button(action: {}) {
                        Text("Schedule Task")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 15)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical)
        }
    }
}

extension ScheduleTaskView {
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
    
    private func daysInMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else {
            return []
        }
        return range.compactMap { day -> Date? in
            var components = calendar.dateComponents([.year, .month], from: currentDate)
            components.day = day
            return calendar.date(from: components)
        }
    }
    
    private func firstWeekday() -> Int {
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstOfMonth = calendar.date(from: components) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday + 5) % 7 // adjust so all weeks thats on monday
    }
    
    private func incrementMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
    private func decrementMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func isCurrentDate(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
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

