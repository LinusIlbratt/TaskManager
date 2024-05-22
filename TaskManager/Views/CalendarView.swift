//
//  CalendarView.swift
//  TaskManager
//
//  Created by Mattias Axelsson on 2024-05-21.
//

import SwiftUI

struct CalendarView: View {
    
    let days: [CalendarDay] = [
        CalendarDay(day: 13, weekday: "Mon", isToday: false, hasEvents: 2),
        CalendarDay(day: 14, weekday: "Tue", isToday: true, hasEvents: 3),
        CalendarDay(day: 15, weekday: "Wed", isToday: false, hasEvents: 0),
        CalendarDay(day: 16, weekday: "Thu", isToday: false, hasEvents: 1),
        CalendarDay(day: 17, weekday: "Fri", isToday: false, hasEvents: 10),
        CalendarDay(day: 18, weekday: "Sat", isToday: false, hasEvents: 3),
        CalendarDay(day: 19, weekday: "Sun", isToday: false, hasEvents: 0)
    ]
    
    @State private var selectedDayIndex: Int? = nil
    
    var body: some View {
        VStack {
            // Month and year header
            HStack {
                Text("May 2024")
                    .font(.headline)
                    .padding()
                Spacer()
            }
            
            GeometryReader { geometry in
                let totalSpacing: CGFloat = 80 // Total space for padding (20 on each side and 10 between each box)
                let itemWidth = max((geometry.size.width - totalSpacing) / 7, 0) // Dynamic width calculation of each box with a fallback
                
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
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(height: 115)
        }
    }
}

struct CalendarDay: Identifiable {
    var id = UUID()
    var day: Int
    var weekday: String
    var isToday: Bool
    var hasEvents: Int // Number of events
}
