//
//  CalendarView.swift
//  TaskManager
//
//  Created by Mattias Axelsson on 2024-05-21.
//

import SwiftUI

struct CalendarView: View {
    
    @Binding var selectedDate: Date?
    
    @State private var days: [CalendarDay] = []
    @State private var selectedDayIndex: Int?
    
    let calendar = Calendar.current
    
    var body: some View {
        VStack {
            //Month and year header
            HStack {
                Text(getMonthYearHeader())
                    .font(.headline)
                    .padding()
                Spacer()
            }
            
            //Get screen size from GeometryReader
            GeometryReader { geometry in
                let totalSpacing: CGFloat = 80 //Total space including padding (20 on each side and 10 between each box)
                let itemWidth = max((geometry.size.width - totalSpacing) / 7, 0) //Dynamic width calculation of each box with a fallback
                
                HStack(spacing: 10) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        VStack {
                            Text("\(day.day)")
                                .font(.title3)
                                .padding(.top, 5)
                                .foregroundColor(selectedDayIndex == index ? Color.white : Color.black)
                            Text(day.weekday)
                                .font(.subheadline)
                                .foregroundColor(selectedDayIndex == index ? Color.white : Color.black)
                            
                            Spacer()
                            
                            // Allows for 2 rows of dots
                            VStack(spacing: 2) {
                                HStack(spacing: 2) {
                                    ForEach(0..<min(day.hasEvents, 5), id: \.self) { _ in
                                        Circle()
                                            .fill(selectedDayIndex == index ? Color.white : Color.black)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                if day.hasEvents > 5 {
                                    HStack(spacing: 2) {
                                        ForEach(5..<day.hasEvents, id: \.self) { _ in
                                            Circle()
                                                .fill(selectedDayIndex == index ? Color.white : Color.black)
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                            
                            // If the date is today, change color
                            if day.isToday {
                                Text("Today")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 5)
                            }
                        }
                        .frame(width: itemWidth, height: 100)
                        .background(selectedDayIndex == index ? Color.black : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedDayIndex = index
                            if let startOfWeek = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: Date()) - 2), to: Date()) {
                                selectedDate = calendar.date(byAdding: .day, value: index, to: startOfWeek)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 115)
        }
        //when the view is shown, lets setup the current week to be displayed
        .onAppear(perform: setupWeek)
    }
    
    func setupWeek() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        //Adjusting to get Monday as start day of the week as normal people
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 2), to: today)!
        
        var weekDays: [CalendarDay] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let day = calendar.component(.day, from: date)
                let isToday = calendar.isDate(date, inSameDayAs: today)
                let weekdaySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                weekDays.append(CalendarDay(day: day, weekday: weekdaySymbol, isToday: isToday, hasEvents: 2)) // Use a fixed number for hasEvents
            }
        }
        self.days = weekDays
        self.selectedDayIndex = weekDays.firstIndex(where: { $0.isToday })
    }
    
    //Get the month and year for the header
    func getMonthYearHeader() -> String {
        let calendar = Calendar.current
        let today = Date()
        let month = calendar.component(.month, from: today)
        let year = calendar.component(.year, from: today)
        
        let dateFormatter = DateFormatter()
        let monthName = dateFormatter.monthSymbols[month - 1]
        
        return "\(monthName) \(year)"
    }
        
    
}

//Struct to handle calendarview on top of task list
struct CalendarDay: Identifiable {
    var id = UUID()
    var day: Int
    var weekday: String
    var isToday: Bool
    var hasEvents: Int //Number of tasks.. perhaps remove?
}
