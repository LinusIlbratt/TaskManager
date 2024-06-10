//
//  ScheduleTaskView.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-05-22.
//

import SwiftUI
import UserNotifications

struct ScheduleTaskView: View {
    @State private var currentDate = Date()
    @State private var selectedDates: Set<Date> = []
    @State private var showGroupList = false
    @State private var selectedGroups: Set<Groups> = []
    @State private var showTimePicker = false
    @State private var alarmTime = Date()
    @ObservedObject var viewModel: TaskViewModel
    @ObservedObject var userVM: UserViewModel
    @StateObject var firebaseService = FirebaseService()
    @Environment(\.dismiss) var dismiss
    var task: Task?
    
    init(viewModel: TaskViewModel, task: Task?) {
            self.viewModel = viewModel
            self.userVM = UserViewModel() // Initiera userVM här
            self.task = task
            _selectedDates = State(initialValue: Set(task?.dueDates ?? []))
        }
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                TopBar()
                ScheduleTaskHeader()
                TaskInfoView(task: task)
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
                
                ScheduleCalendarView(currentDate: $currentDate, selectedDates: $selectedDates)
                
                Spacer()
                
                ActionButtonView(
                    showTimePicker: $showTimePicker,
                    alarmTime: $alarmTime,
                    firebaseService: firebaseService,
                    showGroupList: $showGroupList,
                    selectedGroups: $selectedGroups,
                    task: task,
                    viewModel: viewModel,
                    selectedDates: $selectedDates,
                    dismiss: dismiss
                )
            }
            .padding(.vertical, 40)
            
            if showGroupList {
                GroupsListView(isPresented: $showGroupList, selectedGroups: $selectedGroups)
                    .environmentObject(userVM)
                    .zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            requestNotificationPermission()
            if let task = task, let dueDates = task.dueDates, !dueDates.isEmpty {
                if let firstDueDate = dueDates.first {
                    currentDate = firstDueDate
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Request Authorization Failed: \(error.localizedDescription)")
            }
        }
    }
}


struct ScheduleTaskView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleTaskView(viewModel: TaskViewModel(), task: Task(
            id: "1",
            title: "Example Task",
            description: "This is an example task",
            dueDates: [Date()],
            specificDate: Date(),
            isCompleted: false,
            assignedTo: ["User"],
            createdBy: "User",
            createdAt: Date(),
            familyId: "Family1",
            taskColor: "Red",
            numberOfFishes: 5
        ))
    }
}

struct ScheduleTaskHeader: View {
    var body: some View {
        HStack {
            Text("Schedule Task")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct TaskInfoView: View {
    var task: Task?
    
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
                if let task = task {
                    Text(task.title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(task.title)
                        .font(.headline)
                    
                    Text(task.description)
                        .font(.caption)
                } else {
                    Text("No task selected")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .padding()
    }
}

struct ScheduleCalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedDates: Set<Date>
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        self.decrementMonth()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                        .foregroundColor(.black)
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
                        .foregroundColor(.black)
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
            
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0..<self.firstWeekday(), id: \.self) { _ in
                    Text("")
                        .frame(maxWidth: .infinity)
                }
                
                ForEach(self.daysInMonth(), id: \.self) { date in
                    ZStack {
                        if selectedDates.contains(date) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.clear)
                        }
                        
                        if self.isCurrentDate(date) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
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
                    .frame(minWidth: 35, maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .padding(.horizontal)
    }
}

struct ActionButtonView: View {
    @Binding var showTimePicker: Bool
    @Binding var alarmTime: Date
    @ObservedObject var firebaseService: FirebaseService
    @Binding var showGroupList: Bool
    @Binding var selectedGroups: Set<Groups>
    var task: Task?
    var viewModel: TaskViewModel
    @Binding var selectedDates: Set<Date>
    var dismiss: DismissAction
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                showTimePicker.toggle()
            }) {
                Text("Set Alarm")
                    .buttonStyle()
            }
            .sheet(isPresented: $showTimePicker) {
                VStack {
                    Text("Select Alarm Time")
                        .font(.headline)
                        .padding()
                    
                    DatePicker("Alarm Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                    
                    Button(action: {
                        showTimePicker = false
                    }) {
                        Text("Set Alarm")
                            .buttonStyle()
                    }
                }
                .padding()
            }
            
            Button(action: {
                showGroupList.toggle()
            }) {
                Text("Assign group")
                    .buttonStyle()
            }
            
            if !selectedGroups.isEmpty {
                Text("Selected Groups: \(selectedGroups.map { $0.name }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if showGroupList {
                GroupsListView(isPresented: $showGroupList, selectedGroups: $selectedGroups)
                    .environmentObject(userViewModel)
            }
            
            Spacer().frame(height: 20)
            
            Button(action: {
                if let task = task {
                    viewModel.updateTaskDueDates(task: task, dueDates: Array(selectedDates))
                    viewModel.updateTaskAssignedTo(task: task, assignedTo: selectedGroups.compactMap { $0.id })
                    if let firstDate = selectedDates.first {
                        scheduleNotification(for: firstDate)
                    }
                    dismiss()
                }
            }) {
                Text("Schedule Task")
                    .font(.headline)
                    .foregroundColor(.black)
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
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
    
    private func scheduleNotification(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Alarm"
        content.body = "It's time to \(task?.title ?? "complete your task")"
        content.sound = UNNotificationSound.default
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: \(error.localizedDescription)")
            }
        }
    }
}


struct GroupsListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var isPresented: Bool
    @Binding var selectedGroups: Set<Groups>
    @State private var groups: [Groups] = []

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Select Group")
                    .font(.headline)
                    .padding()
                
                List(groups) { group in
                    HStack {
                        Text(group.name)
                        Spacer()
                        if selectedGroups.contains(group) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedGroups.contains(group) {
                            selectedGroups.remove(group)
                        } else {
                            selectedGroups.insert(group)
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Close")
                            .padding()
                            .foregroundColor(.black)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.5))
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black, lineWidth: 1)
                                }
                            )
                    }
                    .padding()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Add")
                            .padding()
                            .foregroundColor(.black)
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
            }
            .frame(width: 300, height: 400)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .onAppear {
                userViewModel.getMyGroups { fetchedGroups in
                    self.groups = fetchedGroups
                }
            }
        }
    }
}



/*
struct UsersListView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @Binding var isPresented: Bool
    @Binding var selectedUsers: Set<User>
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Select User")
                    .font(.headline)
                    .padding()
                
                List(firebaseService.users) { user in
                    HStack {
                        Text(user.displayName)
                        Spacer()
                        if selectedUsers.contains(user) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedUsers.contains(user) {
                            selectedUsers.remove(user)
                        } else {
                            selectedUsers.insert(user)
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Close")
                            .padding()
                            .foregroundColor(.black)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.5))
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.black, lineWidth: 1)
                                }
                            )
                    }
                    .padding()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Add")
                            .padding()
                            .foregroundColor(.black)
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
            }
            .frame(width: 300, height: 400)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
 */

extension ScheduleCalendarView {
    
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func firstWeekday() -> Int {
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstOfMonth = calendar.date(from: components) else {
            return 0
        }
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday + 5) % 7 // adjust so all weeks starts on Monday
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
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func isCurrentDate(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func incrementMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
    private func decrementMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
}
