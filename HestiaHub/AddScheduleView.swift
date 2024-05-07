//
//  AddScheduleView.swift
//  HestiaHub
//
//  Created by 朱麟凱 on 4/29/24.
//

import SwiftUI

enum ScheduleType: String, CaseIterable, Identifiable {
    case vaccination = "Vaccination"
    case healthCheck = "Health Check-Up"
    
    var id: String { self.rawValue }
}

struct AddScheduleView: View {
    var profile: Profiles
    @State private var notes: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var checkUpRecurring: Bool = false
    @State private var selectedWeekday: Int = 2
    @State private var recurrenceFrequency = 1  // How often the event recurs
    @State private var recurrenceUnit = "Weeks"
    @State private var someEndDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var scheduleDate = Date()
    @State private var showAlert = false // State to control alert visibility
    @State private var alertMessage = "" // The message to be displayed in the alert
    @State private var scheduleType = "Vaccination" // Default type, can be "Vaccination" or "HealthCheckUp"
    @State private var vaccinationType = ""
    @State private var healthCheckUpType = ""
    @State private var selectedVaccineInfo: VaccineInfo?
    
    func scheduleNotificationV(for schedule: VaccinationSchedule) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(schedule.vaccineType ?? "Appointment")"
        content.body = "Your vaccination \(schedule.vaccineType ?? "appointment") is coming up in 10 minutes."
        content.sound = UNNotificationSound.default

        if let date = schedule.date {
            let triggerDate = Calendar.current.date(byAdding: .minute, value: -10, to: date)!
            let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleNotificationH(for schedule: HealthCheckUpSchedule) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(schedule.checkUpType ?? "Appointment")"
        content.body = "Your health check-up\(schedule.checkUpType ?? "appointment") is coming up in 10 minutes."
        content.sound = UNNotificationSound.default

        if let date = schedule.date {
            let triggerDate = Calendar.current.date(byAdding: .minute, value: -10, to: date)!
            let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    let vaccinationSchedules: [String: VaccineInfo] = [
        "-": VaccineInfo(
            name: "-",
            ageOfFirstDose: "-",
            dosesInPrimarySeries: 1,
            minIntervalBetweenDoses: "-",
            boosterDoseInterval: nil,
            recommendedFor: ["-"],
            group: "all"
        ),
        "BCG": VaccineInfo(
            name: "BCG",
            ageOfFirstDose: "at birth",
            dosesInPrimarySeries: 1,
            minIntervalBetweenDoses: "NA",
            boosterDoseInterval: nil,
            recommendedFor: ["infants in countries with a high incidence of tuberculosis"],
            group: "child"
        ),
        "Hepatitis B": VaccineInfo(
            name: "Hepatitis B",
            ageOfFirstDose: "at birth (<24h)",
            dosesInPrimarySeries: 3,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: nil,
            recommendedFor: ["all newborns"],
            group: "child"
        ),
        "Polio": VaccineInfo(
            name: "Polio",
            ageOfFirstDose: "2 months",
            dosesInPrimarySeries: 4,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: "4-6 years",
            recommendedFor: ["all children"],
            group: "child"
        ),
        "DTP": VaccineInfo(
            name: "DTP",
            ageOfFirstDose: "2 months",
            dosesInPrimarySeries: 5,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: "4-6 years",
            recommendedFor: ["all children"],
            group: "child"
        ),
        "Haemophilus influenzae type b": VaccineInfo(
            name: "Haemophilus influenzae type b",
            ageOfFirstDose: "2 months",
            dosesInPrimarySeries: 3,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: nil,
            recommendedFor: ["all children"],
            group: "child"
        ),
        "Pneumococcal": VaccineInfo(
            name: "Pneumococcal",
            ageOfFirstDose: "2 months",
            dosesInPrimarySeries: 3,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: nil,
            recommendedFor: ["all children"],
            group: "child"
        ),
        "Rotavirus": VaccineInfo(
            name: "Rotavirus",
            ageOfFirstDose: "2 months",
            dosesInPrimarySeries: 2,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: nil,
            recommendedFor: ["all children"],
            group: "child"
        ),
        "Measles": VaccineInfo(
            name: "Measles",
            ageOfFirstDose: "9 months",
            dosesInPrimarySeries: 2,
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: nil,
            recommendedFor: ["all children"],
            group: "child"
        ),
        "Rubella": VaccineInfo(
            name: "Rubella",
            ageOfFirstDose: "12 months",
            dosesInPrimarySeries: 1,
            minIntervalBetweenDoses: "NA",
            boosterDoseInterval: nil,
            recommendedFor: ["all children and women of reproductive age"],
            group: "all"
        ),
        "HPV": VaccineInfo(
            name: "HPV",
            ageOfFirstDose: "9-14 years",
            dosesInPrimarySeries: 2,
            minIntervalBetweenDoses: "6 months",
            boosterDoseInterval: nil,
            recommendedFor: ["girls and boys for cancer prevention"],
            group: "all"
        ),
        "Influenza": VaccineInfo(
            name: "Seasonal Influenza",
            ageOfFirstDose: "6 months",
            dosesInPrimarySeries: 1, // May vary; some children require two doses
            minIntervalBetweenDoses: "4 weeks",
            boosterDoseInterval: "annually",
            recommendedFor: ["all individuals, especially high-risk groups"],
            group: "all"
        ),
        "Japanese Encephalitis": VaccineInfo(
            name: "Japanese Encephalitis",
            ageOfFirstDose: "9 months",
            dosesInPrimarySeries: 2,
            minIntervalBetweenDoses: "1 years",
            boosterDoseInterval: nil,
            recommendedFor: ["children in endemic areas"],
            group: "child"
        ),
        "Yellow Fever": VaccineInfo(
            name: "Yellow Fever",
            ageOfFirstDose: "9 months",
            dosesInPrimarySeries: 1,
            minIntervalBetweenDoses: "NA",
            boosterDoseInterval: "10 years",
            recommendedFor: ["residents of and travelers to endemic areas"],
            group: "all"
        ),
        "Cholera": VaccineInfo(
            name: "Cholera",
            ageOfFirstDose: "2 years",
            dosesInPrimarySeries: 2,
            minIntervalBetweenDoses: "2 weeks",
            boosterDoseInterval: "2 years for high-risk populations",
            recommendedFor: ["travelers and populations in endemic areas"],
            group: "all"
        )
        // Additional vaccines as per the WHO recommendations
    ]
    
    private var availableVaccines: [VaccineInfo] {
        // Calculate the age of the profile from their date of birth to today
        let age = Calendar.current.dateComponents([.year], from: profile.dateOfBirth ?? Date(), to: Date()).year ?? 0

        return vaccinationSchedules.values.filter { vaccineInfo in
            switch vaccineInfo.group {
            case "all":
                return true  // Vaccine is applicable to all age groups
            case "child":
                return age < 18  // Vaccine is applicable only to children under 18
            case "adult":
                return age >= 18  // Vaccine is applicable only to adults 18 and older
            default:
                return false  // If the group is not recognized, do not show the vaccine
            }
        }
    }

    private func scheduleVaccinations() {
        guard let vaccineInfo = vaccinationSchedules[vaccinationType] else {
            alertMessage = "Vaccine information not found."
            showAlert = true
            return
        }

        var scheduleDate = self.scheduleDate

        // Create and save the first schedule
        saveVaccination(date: scheduleDate, vaccineType: vaccinationType)

        // Iterate over the number of doses after the first one
        for _ in 1..<vaccineInfo.dosesInPrimarySeries {
            if let nextScheduleDate = getNextScheduleDate(currentDate: scheduleDate, interval: vaccineInfo.minIntervalBetweenDoses) {
                scheduleDate = nextScheduleDate
                saveVaccination(date: scheduleDate, vaccineType: vaccinationType)
            } else {
                alertMessage = "Error calculating the next vaccination date."
                showAlert = true
                return
            }
        }

        do {
            try viewContext.save()
            
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = "There was an error saving the schedules. Please try again."
            showAlert = true
        }
    }

    private func getNextScheduleDate(currentDate: Date, interval: String) -> Date? {
        let calendar = Calendar.current
        var dateComponent = DateComponents()

        // Split the interval into value and unit, e.g., "4 weeks" -> (4, "weeks")
        let split = interval.split(separator: " ")
        if split.count != 2 {
            return nil
        }
        guard let value = Int(split[0]) else { return nil }
        let unit = String(split[1])

        switch unit {
        case "days":
            dateComponent.day = value
        case "weeks":
            dateComponent.weekOfYear = value
        case "months":
            dateComponent.month = value
        case "years":
            dateComponent.year = value
        default:
            return nil
        }
        return calendar.date(byAdding: dateComponent, to: currentDate)
    }


    private func saveVaccination(date: Date, vaccineType: String) {
        let newVaccinationSchedule = VaccinationSchedule(context: viewContext)
        newVaccinationSchedule.date = date
        newVaccinationSchedule.vaccineType = vaccineType
        newVaccinationSchedule.profileID = profile.id
        scheduleNotificationV(for: newVaccinationSchedule)
    }
    
    // Function to check if all fields are filled in
    private func allFieldsValid() -> Bool {
        if scheduleDate <= Date() {
            alertMessage = "Please select a future date for the schedule."
            return false
        }

        if scheduleType == "Vaccination" && vaccinationType.isEmpty {
            alertMessage = "Please enter a vaccine type."
            return false
        } else if scheduleType == "HealthCheckUp" && healthCheckUpType == "" {

            alertMessage = "Please enter a health check-up type."
            return false
        }
        return true
    }

    private func saveSchedule() {
        if !allFieldsValid() {
            showAlert = true
            return
        }

        if scheduleType == "Vaccination" {
            if vaccinationType == "-" {
                alertMessage = "Please select a valid vaccine type from the list."
                showAlert = true
                return
            }
            scheduleVaccinations()
        } else {
            if checkUpRecurring {
                createRecurringSchedules()
            } else {
                let newHealthCheckUpSchedule = HealthCheckUpSchedule(context: viewContext)
                newHealthCheckUpSchedule.date = scheduleDate
                newHealthCheckUpSchedule.checkUpType = healthCheckUpType
                newHealthCheckUpSchedule.profileID = profile.id
                newHealthCheckUpSchedule.notes = notes
                scheduleNotificationH(for: newHealthCheckUpSchedule)
            }
        }

        do {
            try viewContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            alertMessage = "There was an error saving the schedule. Please try again."
            showAlert = true
        }
    }
    
    private func createRecurringSchedules() {
        _ = Calendar.current
        var currentDate = scheduleDate

        while shouldContinueAddingSchedules(currentDate: currentDate) {
            let newSchedule = HealthCheckUpSchedule(context: viewContext)
            newSchedule.date = currentDate
            newSchedule.checkUpType = healthCheckUpType
            newSchedule.profileID = profile.id
            newSchedule.notes = notes
            scheduleNotificationH(for: newSchedule)
            guard let nextDate = calculateNextDate(from: currentDate) else { break }
            currentDate = nextDate
        }
    }

    private func calculateNextDate(from date: Date) -> Date? {
        let calendar = Calendar.current
        var dateComponent = DateComponents()

        switch recurrenceUnit {
        case "Days":
            dateComponent.day = recurrenceFrequency
        case "Weeks":
            dateComponent.weekOfYear = recurrenceFrequency
        case "Months":
            dateComponent.month = recurrenceFrequency
        default:
            return nil
        }

        return calendar.date(byAdding: dateComponent, to: date)
    }

    private func shouldContinueAddingSchedules(currentDate: Date) -> Bool {
        return currentDate <= someEndDate
    }

    
    var body: some View {
        VStack {
            Form {
                DatePicker("Date and Time", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())  // You can choose the style that fits best in your app

                
                Picker("Schedule Type", selection: $scheduleType) {
                    Text("Vaccination").tag("Vaccination")
                    Text("Health Check-Up").tag("HealthCheckUp")
                }
                .pickerStyle(SegmentedPickerStyle())

                if scheduleType == "Vaccination" {
                    Picker("Vaccine Type", selection: $vaccinationType) {
                        ForEach(availableVaccines, id: \.self) { vaccine in
                            Text(vaccine.name).tag(vaccine.name)  // Use the vaccine's name as the tag
                        }
                    }
                    .onAppear {
                        if availableVaccines.first != nil {
                            vaccinationType = "-" // Ensure this is a valid name that can be a tag in the Picker
                        }
                    }

                } else {
                    TextField("Health Check-Up Type", text: $healthCheckUpType)
                    Toggle("Recurring", isOn: $checkUpRecurring)
                    if checkUpRecurring {
                        Picker("Recurrence Unit", selection: $recurrenceUnit) {
                            Text("Days").tag("Days")
                            Text("Weeks").tag("Weeks")
                            Text("Months").tag("Months")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Stepper("Every \(recurrenceFrequency) \(recurrenceUnit)", value: $recurrenceFrequency, in: 1...52)
                        DatePicker(
                                "End Date for Recurring Schedules",
                                selection: $someEndDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                }
                
                // Adding a section for notes
                Section(header: Text("Additional Notes")) {
                    TextField("Enter any additional information here", text: $notes)
                }

                Button("Save", action: saveSchedule)
                    
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Missing Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Add Schedule")
            
        }
    }
}

struct VaccineInfo: Hashable {
    var name: String
    var ageOfFirstDose: String
    var dosesInPrimarySeries: Int
    var minIntervalBetweenDoses: String
    var boosterDoseInterval: String?
    var recommendedFor: [String]
    var group: String
    
    // Implementation of Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(ageOfFirstDose)
        hasher.combine(dosesInPrimarySeries)
        hasher.combine(minIntervalBetweenDoses)
        hasher.combine(boosterDoseInterval)
        hasher.combine(group)
    }
    
    static func == (lhs: VaccineInfo, rhs: VaccineInfo) -> Bool {
        lhs.name == rhs.name
    }
}


