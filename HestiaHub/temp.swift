//import SwiftUI
//
//// Struct for individual vaccine schedule row
//struct VaccineScheduleRow: View {
//    @ObservedObject var schedule: VaccinationSchedule
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var showingPopover = false
//    @State private var isEditing = false
//    @State private var editedDate: Date?
//
//    var body: some View {
//        HStack {
//            if isEditing {
//                DatePicker("Edit Date:", selection: Binding(get: { editedDate ?? schedule.date ?? Date() }, set: { editedDate = $0 }), displayedComponents: .date)
//                Button("Save") {
//                    if let newDate = editedDate {
//                        schedule.date = newDate
//                        scheduleNotification(for: schedule)
//                        try? viewContext.save()
//                        isEditing = false
//                    }
//                }
//            } else {
//                Text(schedule.vaccineType ?? "Unknown Vaccine")
//                Spacer()
//                Text(formatDate(schedule.date ?? Date()))
//                    .onTapGesture {
//                        showingPopover = true
//                    }
//            }
//        }
//        .popover(isPresented: $showingPopover) {
//            Text(schedule.notes ?? "No additional notes provided.")
//        }
//    }
//
//    private func scheduleNotification(for schedule: VaccinationSchedule) {
//        // Implementation of notification scheduling (Same as previously discussed)
//    }
//
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//}
//
//// Struct for individual health check-up schedule row
//struct HealthCheckUpScheduleRow: View {
//    @ObservedObject var schedule: HealthCheckUpSchedule
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var showingPopover = false
//    @State private var isEditing = false
//    @State private var editedDate: Date?
//
//    var body: some View {
//        HStack {
//            if isEditing {
//                DatePicker("Edit Date:", selection: Binding(get: { editedDate ?? schedule.date ?? Date() }, set: { editedDate = $0 }), displayedComponents: .date)
//                Button("Save") {
//                    if let newDate = editedDate {
//                        schedule.date = newDate
//                        scheduleNotification(for: schedule)
//                        try? viewContext.save()
//                        isEditing = false
//                    }
//                }
//            } else {
//                Text(schedule.checkUpType ?? "Unknown Check-Up")
//                Spacer()
//                Text(formatDate(schedule.date ?? Date()))
//                    .onTapGesture {
//                        showingPopover = true
//                    }
//            }
//        }
//        .popover(isPresented: $showingPopover) {
//            Text(schedule.notes ?? "No additional notes provided.")
//        }
//    }
//
//    private func scheduleNotification(for schedule: HealthCheckUpSchedule) {
//        // Implementation of notification scheduling (Same as previously discussed)
//    }
//
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//}
//
//// Main CalendarView structure
//struct CalendarView: View {
//    @ObservedObject var userProfile: Profiles
//    @Binding var selectedDate: Date
//    @Environment(.managedObjectContext) private var viewContext
//    @State private var showingAddScheduleView = false
//    @State private var isEditMode: EditMode = .inactive
//    @State private var showAlert = false // State to manage alert visibility
//    @State private var alertMessage = ""
//    @FetchRequest var vaccinationSchedules: FetchedResults<VaccinationSchedule>
//    @FetchRequest var healthCheckUpSchedules: FetchedResults<HealthCheckUpSchedule>
//    
//    var body: some View {
//        VStack {
//            DatePicker(
//                "Select Date",
//                selection: $selectedDate,
//                displayedComponents: [.date] // Only show the date picker, not time.
//            )
//            .datePickerStyle(GraphicalDatePickerStyle())
//            .accentColor(.cBlue)
//            .padding(.vertical)
//            
//            Button("Add Appointment") {
//                if userProfile.deceased == "Yes" {
//                    alertMessage = randomHeartwarmingMessage()
//                    showAlert = true
//                } else {
//                    showingAddScheduleView = true
//                }
//            }
//            .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud))
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//            
//            List {
//                Section(header: Text("Vaccination Schedules")) {
//                    ForEach(vaccinationSchedules) { schedule in
//                        if Calendar.current.isDate(schedule.date ?? Date(), inSameDayAs: selectedDate) {
//                            VaccineScheduleRow(schedule: schedule)
//                        }
//                    }
//                    .onDelete(perform: deleteVaccinationSchedule)
//                }
//                
//                Section(header: Text("Health Check-Up Schedules")) {
//                    ForEach(healthCheckUpSchedules) { schedule in
//                        if Calendar.current.isDate(schedule.date ?? Date(), inSameDayAs: selectedDate) {
//                            HealthCheckUpScheduleRow(schedule: schedule)
//                        }
//                    }
//                    .onDelete(perform: deleteHealthCheckUpSchedule)
//                }
//            }
//            .navigationTitle("Schedules")
//            .toolbar {
//                EditButton()
//            }
//            
//            NavigationLink(
//                destination: AddScheduleView(profile: userProfile),
//                isActive: $showingAddScheduleView
//            ) {
//                EmptyView()
//            }
//        }
//    }
//    
//    private func deleteVaccinationSchedule(at offsets: IndexSet) {
//        withAnimation {
//            offsets.map { vaccinationSchedules[$0] }.forEach(viewContext.delete)
//            try? viewContext.save()
//        }
//    }
//    
//    private func deleteHealthCheckUpSchedule(at offsets: IndexSet) {
//        withAnimation {
//            offsets.map { healthCheckUpSchedules[$0] }.forEach(viewContext.delete)
//            try? viewContext.save()
//        }
//    }
//    
//    private func randomHeartwarmingMessage() -> String {
//        let messages = [        "Remembering the joyous moments, we treasure the time spent together.",        "Their memories will live on in our hearts forever.",        "May the love and cherished moments comfort you in this time.",        "May the memories of the wonderful times you shared comfort you in the days ahead.",        "Our hearts are saddened by your loss, and our thoughts and prayers are with you.",        "Our deepest sympathies as you remember \(userProfile.profileName ?? "them").",        "Wishing you peace to bring comfort, courage to face the days ahead, and loving memories to forever hold in your heart."    ]
//        return messages.randomElement() ?? "They will always be remembered."
//    }
//}
