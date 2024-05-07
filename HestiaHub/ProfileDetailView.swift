import SwiftUI
import PDFKit
import UIKit
import Combine
import CoreData

struct ProfileDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var userProfile: Profiles // Assuming Profiles has a one-to-many relationship with a Document entity
    @State private var selectedDate = Date()
        
    // States for Document Picker and Sharing
    @State private var showingDocumentPicker = false
    @State private var selectedDocuments: [URL] = []
        
    // States for Schedule
    @State private var showingAddScheduleView = false

    var body: some View {
        TabView {
            ProfileView(userProfile: userProfile)
                .tabItem {
                    Label("Profile", systemImage: "house.fill")
                }
                //.navigationViewStyle(StackNavigationViewStyle())
            CalendarView(userProfile: userProfile, selectedDate: $selectedDate)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                //.navigationViewStyle(StackNavigationViewStyle())
            DocumentsView(userProfile: userProfile)
                .tabItem {
                    Label("Documents", systemImage: "doc.fill")
                }
                //.navigationViewStyle(StackNavigationViewStyle())
        }
        
        .navigationTitle("Profile Details")
    }
}

struct ProfileView: View {
    @ObservedObject var userProfile: Profiles
    @Environment(\.managedObjectContext) private var viewContext
    var bloodType: String = "A" // Default relationship
    var bloodTypes: [String] = ["A", "B", "O", "AB"]
    var relationship: String = "User" // Default relationship
    //var relationships: [String] = ["User", "Parent", "Kid", "Friend", "Relative", "Grandparent", "Grandchild"]
    var deceased: String = "No"
    var deceasedStatus: [String] = ["No", "Yes"]
    @State var sex: String = "-"
    @State var sexOption: [String] = ["-", "Female", "Male"]
    @State private var isEditing = false
    @State private var editableName: String = ""
    @State private var editableDateOfBirth: Date = Date()
    @State private var editableWeight: String = ""
    @State private var editableHeight: String = ""
    @State private var editableBloodType: String = ""
    @State private var editableRelationship: String = ""
    @State private var editableDeceased: String = ""
    @State private var editableSex: String = ""
    @State private var editableDateOfDeath: Date = Date()
    @State private var editableDeath: String = ""
    
    
    @State private var editablePastSurgeries: String = ""
    @State private var editableOngoingTreatments: String = ""
    @State private var editableHealthConditions: String = ""
    @State private var editableAllergies: String = ""
    
    @FetchRequest(
        entity: Profiles.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "relationship == %@", "User")
    ) var existingUserProfiles: FetchedResults<Profiles>

    private var relationships: [String] {
        if existingUserProfiles.isEmpty {
            return ["User", "Parent", "Kid", "Friend", "Relative", "Grandparent", "Grandchild"]  // All relationships available
        } else {
            return ["Parent", "Kid", "Friend", "Relative", "Grandparent", "Grandchild"]  // Exclude 'User' if already used
        }
    }
    
    
    var body: some View {
        VStack {
            if isEditing {
                Button("Save Changes") {
                    isEditing.toggle()
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
            } else {
                Button("Edit") {
                    isEditing.toggle()
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
            }

            Form {
                Section(header: Text("Profile Info")) {
                    if isEditing {
                        TextField("Name", text: $editableName)
                        DatePicker("Date of Birth", selection: $editableDateOfBirth, displayedComponents: .date)
                            .accentColor(.cBlue)
                        TextField("Weight (kg)", text: $editableWeight)
                        TextField("Height (cm)", text: $editableHeight)
                        Picker("Blood Type", selection: $editableBloodType) {
                            ForEach(bloodTypes, id: \.self) { bloodType in
                                Text(bloodType).tag(bloodType)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.cBlue)
                        Picker("Sex", selection: $editableSex) {
                            ForEach(sexOption, id: \.self) { sex in
                                Text(sex).tag(sex)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.cBlue)
                        Picker("Relationship", selection: $editableRelationship) {
                            ForEach(relationships, id: \.self) { relationship in
                                Text(relationship).tag(relationship)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.cBlue)
                        Picker("Deceased", selection: $editableDeceased) {
                            ForEach(deceasedStatus, id: \.self) { deceased in
                                Text(deceased).tag(deceased)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.cBlue)
                        if editableDeceased == "Yes" {
                            DatePicker("Date of Death", selection: $editableDateOfDeath, displayedComponents: .date)
                                .accentColor(.cBlue)
                            TextField("Cause of Death", text: $editableDeath)
                        }
                        TextField("Past Surgeries", text: $editablePastSurgeries)
                        TextField("Ongoing Treatments", text: $editableOngoingTreatments)
                        TextField("Health Conditions", text: $editableHealthConditions)
                        TextField("Allergies", text: $editableAllergies)
                        
                    } else {
                        Text("Name: \(userProfile.profileName ?? "N/A")")
                        Text("Date of Birth: \(formattedDate(userProfile.dateOfBirth))")
                        Text("Age: \(userProfile.age) year-old")
                        Text("Weight: \(userProfile.weight) kg")
                        Text("Height: \(userProfile.height) cm")
                        Text("Blood Type: \(userProfile.bloodType ?? "N/A")")
                        Text("Sex: \(userProfile.sex ?? "N/A")")
                        Text("Relationship: \(userProfile.relationship ?? "N/A")")
                        if userProfile.deceased == "Yes" {
                            Text("Deceased")
                            Text("Date of Death: \(formattedDate(userProfile.dateOfDeath))")
                            if userProfile.reasonOfDeath != "" {
                                Text("Cause of Death: \(userProfile.reasonOfDeath ?? "")")
                            }
                        }
                        if userProfile.pastSurgeries != "" {
                            Text("Past Surgeries: \(userProfile.pastSurgeries ?? "")")
                        }
                        if userProfile.ongoingTreatments != "" {
                            Text("Ongoing Treatments: \(userProfile.ongoingTreatments ?? "")")
                        }
                        if userProfile.healthConditions != "" {
                            Text("Health Conditions: \(userProfile.healthConditions ?? "")")
                        }
                        if userProfile.allergies != "" {
                            Text("Allergies: \(userProfile.allergies ?? "")")
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Profile Info")
        .onAppear {
            // Initialize editable fields with current profile data
            self.editableName = userProfile.profileName ?? ""
            self.editableDateOfBirth = userProfile.dateOfBirth ?? Date()
            self.editableWeight = "\(userProfile.weight)"
            self.editableHeight = "\(userProfile.height)"
            self.editableBloodType = userProfile.sex ?? ""
            self.editableSex = userProfile.bloodType ?? ""
            self.editableRelationship = userProfile.relationship ?? ""
            self.editableDeceased = userProfile.deceased ?? ""
            self.editableDateOfDeath = userProfile.dateOfDeath ?? Date()
            self.editableDeath = userProfile.reasonOfDeath ?? ""
            self.editablePastSurgeries = userProfile.pastSurgeries ?? ""
            self.editableOngoingTreatments = userProfile.ongoingTreatments ?? ""
            self.editableHealthConditions = userProfile.healthConditions ?? ""
            self.editableAllergies = userProfile.allergies ?? ""
        }
        .onChange(of: isEditing) { editing in
            if !editing {
                // Save the edited profile information when exiting edit mode
                saveProfile()
            }
        }
    }

    private func formattedDate(_ date: Date?) -> String {
         guard let date = date else { return "N/A" }
         let formatter = DateFormatter()
         formatter.dateStyle = .medium
         formatter.timeStyle = .none // No time component
         return formatter.string(from: date)
     }
    
    private func saveProfile() {
        userProfile.profileName = editableName
        userProfile.dateOfBirth = editableDateOfBirth
        userProfile.profileName = editableName
        userProfile.dateOfDeath = editableDateOfDeath
        userProfile.reasonOfDeath = editableDeath
        userProfile.weight = Int16(editableWeight) ?? 1
        userProfile.height = Int16(editableHeight) ?? 30
        if editableDeceased == "Yes" {
            userProfile.age = Int16(calculateAge(from: editableDateOfBirth, dateOfDeath: editableDateOfDeath))
        } else {
            userProfile.age = Int16(calculateAge(from: editableDateOfBirth, dateOfDeath: Date()))
        }
        userProfile.bloodType = editableBloodType
        userProfile.sex = editableSex
        userProfile.relationship = editableRelationship
        userProfile.deceased = editableDeceased
        userProfile.pastSurgeries = editablePastSurgeries
        userProfile.ongoingTreatments = editableOngoingTreatments
        userProfile.healthConditions = editableHealthConditions
        userProfile.allergies = editableAllergies
        do {
            try viewContext.save()
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}

// This is your CalendarView
struct CalendarView: View {
    @ObservedObject var userProfile: Profiles
    @Binding var selectedDate: Date
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddScheduleView = false
    @State private var isEditMode: EditMode = .inactive
    @State private var showAlert = false // State to manage alert visibility
    @State private var alertMessage = ""
    
    @FetchRequest var vaccinationSchedules: FetchedResults<VaccinationSchedule>
    @FetchRequest var healthCheckUpSchedules: FetchedResults<HealthCheckUpSchedule>
    
    @State private var editedScheduleDate: Date?
    @State private var isEditingSchedule = false
    @State private var editableVaccineSchedule: VaccinationSchedule?
    @State private var editableCheckUpSchedule: HealthCheckUpSchedule?
    
    @State private var showingNotePopover = false
    @State private var currentNote = ""
    
    func randomHeartwarmingMessage() -> String {
        let messages = [
            "Remembering the joyous moments, we treasure the time spent together.",
            "Their memories will live on in our hearts forever.",
            "May the love and cherished moments comfort you in this time.",
            "May the memories of the wonderful times you shared comfort you in the days ahead.",
            "Our hearts are saddened by your loss, and our thoughts and prayers are with you.",
            "Our deepest sympathies as you remember \(userProfile.profileName ?? "them").",
            "Wishing you peace to bring comfort, courage to face the days ahead, and loving memories to forever hold in your heart."
        ]
        return messages.randomElement() ?? "They will always be remembered."
    }

    init(userProfile: Profiles, selectedDate: Binding<Date>) {
        self._userProfile = ObservedObject(wrappedValue: userProfile)
        self._selectedDate = selectedDate

        let profileID = userProfile.id ?? UUID() // Provide a default UUID if nil which should ideally never be used in fetching.

        // Initialize FetchRequests using userProfile safely
        self._vaccinationSchedules = FetchRequest(
            entity: VaccinationSchedule.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \VaccinationSchedule.date, ascending: true)],
            predicate: NSPredicate(format: "profileID == %@", profileID as CVarArg)
        )
        
        self._healthCheckUpSchedules = FetchRequest(
            entity: HealthCheckUpSchedule.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \HealthCheckUpSchedule.date, ascending: true)],
            predicate: NSPredicate(format: "profileID == %@", profileID as CVarArg)
        )
    }
    
    // Function to delete a vaccination schedule
    private func deleteVaccinationSchedule(at offsets: IndexSet) {
        withAnimation {
            offsets.map { vaccinationSchedules[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // Function to delete a health check-up schedule
    private func deleteHealthCheckUpSchedule(at offsets: IndexSet) {
        withAnimation {
            offsets.map { healthCheckUpSchedules[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short  // Set the formatter to show short time style
        formatter.dateStyle = .none  // We don't need the date part
        return formatter.string(from: date)
    }    
    
    var body: some View {
        VStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date] // Only show the date picker, not time.
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(.cBlue)
                .scaleEffect(0.8) // Scale down to 75% of the original size
                .padding(.top, -60)
                //.padding()
                
                Button("Add Appointment") {
                    if userProfile.deceased == "Yes" {
                        alertMessage = randomHeartwarmingMessage()
                        showAlert = true
                    } else {
                        showingAddScheduleView = true
                    }
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
                .padding(.top, -50)
                Button(isEditingSchedule ? "Finish Editing" : "Edit Schedule") {
                    // Toggle the editing state
                    isEditingSchedule.toggle()
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
                .padding(.top, -25)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Notice: Deceased Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                

                //.padding()
            }
            //.padding()
            // Here is where we list out the schedules for the selectedDate
            List {
                Section(header: Text("Vaccination Schedules")) {
                    if isEditingSchedule {
                        ForEach(vaccinationSchedules) { schedule in
                            if Calendar.current.isDate(schedule.date ?? Date(), inSameDayAs: selectedDate) {
                                Text(schedule.vaccineType ?? "Unknown Vaccine")
                                
                                // Show the DatePicker only for the schedule that matches the selected date
                                DatePicker(
                                    "Editing \(schedule.vaccineType ?? "Vaccine")",
                                    selection: Binding(get: {
                                        editedScheduleDate ?? schedule.date ?? Date()
                                    }, set: {
                                        editedScheduleDate = $0
                                    })
                                )
                                .datePickerStyle(CompactDatePickerStyle())
                                .onDisappear {
                                    // When the DatePicker disappears, save the changes
                                    saveChangesV(for: schedule)
                                }
                            }
                        }
                        .onDelete(perform: deleteVaccinationSchedule)
                    } else {
                        ForEach(vaccinationSchedules) { schedule in
                            if Calendar.current.isDate(schedule.date ?? Date(), inSameDayAs: selectedDate) {
                                scheduleRowV(schedule)
                            }
                        }
                        .onDelete(perform: deleteVaccinationSchedule)
                    }
                }
                    
                
                Section(header: Text("Health Check-Up Schedules")) {
                    if isEditingSchedule {
                        ForEach(healthCheckUpSchedules) { schedule in
                            if Calendar.current.isDate(schedule.date ?? Date(), inSameDayAs: selectedDate) {
                                Text(schedule.checkUpType ?? "Unknown Check-Up")
                                
                                // Show the DatePicker only for the schedule that matches the selected date
                                DatePicker(
                                    "Editing \(schedule.checkUpType ?? "Check-Up")",
                                    selection: Binding(get: {
                                        editedScheduleDate ?? schedule.date ?? Date()
                                    }, set: {
                                        editedScheduleDate = $0
                                    })
                                )
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(.cBlue)
                                .onDisappear {
                                    // When the DatePicker disappears, save the changes
                                    saveChangesH(for: schedule)
                                }
                            }
                        }
                        .onDelete(perform: deleteVaccinationSchedule)
                    } else {
                        ForEach(healthCheckUpSchedules) { schedule in
                            if Calendar.current.isDate(schedule.date ?? Date(), inSameDayAs: selectedDate) {
                                scheduleRowH(schedule)
                            }
                        }
                        .onDelete(perform: deleteHealthCheckUpSchedule)
                        .accentColor(.cBlue)
                    }
                }
            }

            .navigationTitle("Schedules")

            .background(
                NavigationLink(
                    destination: AddScheduleView(profile: userProfile),
                    isActive: $showingAddScheduleView
                ) {
                    EmptyView()
                }
                    .hidden() // Hide the NavigationLink so it doesn't interfere with the UI
            )

        }
    }
    
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
    
    // Helper view to create a schedule row
    private func scheduleRowH(_ schedule: HealthCheckUpSchedule) -> some View {
        HStack {
            Text(schedule.checkUpType ?? "Unknown Check-Up")
            Spacer()
            Text(formatDate(schedule.date ?? Date()))
                .onTapGesture {
                    currentNote = schedule.notes ?? "No additional notes provided."
                    showingNotePopover = true
                }
                if showingNotePopover {
                    // Overlay content
                    VStack {
                        Text(currentNote)
                        Button("Close") {
                            showingNotePopover = false
                        }
                        .accentColor(.cBlue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
                    .onTapGesture {
                        showingNotePopover = false
                    }
                }
        }
    }
    
    private func scheduleRowV(_ schedule: VaccinationSchedule) -> some View {
        HStack {
            Text(schedule.vaccineType ?? "Unknown Vaccine")
            Spacer()
            Text(formatDate(schedule.date ?? Date()))
                .onTapGesture {
                    currentNote = schedule.notes ?? "No additional notes provided."
                    showingNotePopover = true
                }
                if showingNotePopover {
                    // Overlay content
                    VStack {
                        Text(currentNote)
                        Button("Close") {
                            showingNotePopover = false
                        }
                        .accentColor(.cBlue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
                    .onTapGesture {
                        showingNotePopover = false
                    }
                }
        }
    }
    
    private func beginEditingV(_ schedule: VaccinationSchedule) {
        editableVaccineSchedule = schedule
        editedScheduleDate = schedule.date
        isEditingSchedule = true
    }
    
    private func saveChangesV(for schedule: VaccinationSchedule) {
        guard let newDate = editedScheduleDate else { return }
        schedule.date = newDate
        scheduleNotificationV(for: schedule)
        try? viewContext.save()
        isEditingSchedule = false
    }
    
    private func beginEditingH(_ schedule: HealthCheckUpSchedule) {
        editableCheckUpSchedule = schedule
        editedScheduleDate = schedule.date
        isEditingSchedule = true
    }
    
    private func saveChangesH(for schedule: HealthCheckUpSchedule) {
        guard let newDate = editedScheduleDate else { return }
        schedule.date = newDate
        scheduleNotificationH(for: schedule)
        try? viewContext.save()
        isEditingSchedule = false
    }
    
}

struct DocumentsView: View {
    let maxFileSize = 10 * 1024 * 1024  // 10 MB in bytes
    let maxTotalSize = 50 * 1024 * 1024  // 50 MB in bytes
    @ObservedObject var userProfile: Profiles
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest var documents: FetchedResults<Document>
    
    @State private var showingDocumentPicker = false
    @State private var selectedExportDocuments = Set<Document.ID>()
    @State private var showingShareSheet = false
    @State private var activityItems: [URL] = []
    @State private var isInExportMode = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var image: UIImage?
    @State private var showingPicker = false
    @State private var sourceType: PickerSourceType = .camera
    @State private var refreshID = UUID()

    
    let maxExportLimit = 20  // Maximum number of documents that can be selected for export

    init(userProfile: Profiles) {
        self.userProfile = userProfile

        // Use optional binding to safely unwrap userProfile.id
        if let profileID = userProfile.id {
            let predicate = NSPredicate(format: "profileID == %@", profileID as CVarArg)
            _documents = FetchRequest<Document>(
                entity: Document.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \Document.fileName, ascending: true)],
                predicate: predicate
            )
        } else {
            // Handle the case where userProfile.id is nil by setting up a fetch request that will not return any results
            _documents = FetchRequest<Document>(
                entity: Document.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \Document.fileName, ascending: true)],
                predicate: NSPredicate(format: "1 == 0")  // This predicate ensures no documents will match
            )
        }
    }
    
    private func refreshDocuments() {
        documents.nsPredicate = NSPredicate(format: "profileID == %@", userProfile.id! as CVarArg)
    }
    
    private func exportDocuments() {
        let documentsToExport = documents.filter { selectedExportDocuments.contains($0.id)
        }.compactMap { document -> URL? in guard let data = document.fileData else { return nil }
                let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(document.fileName ?? "temp.pdf")
                do {
                    try data.write(to: tmpURL)
                    return tmpURL
                } catch {
                    print("Failed to write file data for export: \(error)")
                    return nil
                }
            }
            if !documentsToExport.isEmpty {
                activityItems = documentsToExport
                showingShareSheet = true
                selectedExportDocuments.removeAll()  // Clear selections after export
                isInExportMode = false  // Reset export mode after sharing
            }
        }
    
        private func deleteDocuments(at offsets: IndexSet) {
            for index in offsets {
                let document = documents[index]
                viewContext.delete(document)
            }
    
            do {
                try viewContext.save()
            } catch {
                print("Error saving context after deleting documents: \(error)")
            }
        }
    
    var body: some View {
        VStack {
            List {
                ForEach(documents) { document in
                    DocumentRow(document: document, forceUpdate: false, isInExportMode: $isInExportMode, selectedExportDocuments: $selectedExportDocuments)
                }
                .onDelete(perform: deleteDocuments)
            }
            .padding(.top,10)
            .navigationTitle("Documents")
            .onAppear {
                self.documents.nsPredicate = NSPredicate(format: "profileID == %@", userProfile.id! as CVarArg)
            }

//            .toolbar {
//                if isInExportMode {
//                    Button("Export Selected") {
//                        exportDocuments()
//                    }
//                    .disabled(selectedExportDocuments.isEmpty)
//                }
//            }
            
            .sheet(isPresented: $showingShareSheet) {
                ActivityView(activityItems: activityItems)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            if isInExportMode {
                Button("Approve Export") {
                    exportDocuments()
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
                .disabled(selectedExportDocuments.isEmpty)
            }
            Button("Upload From Device") {
                showingDocumentPicker = true
            }
            .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
//            Button("Take Photo") {
//                showingCamera = true
//            }
//            .sheet(isPresented: $showingCamera) {
//                CameraPicker(image: $image)
//            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker(profile: userProfile,
                        selectedDocuments: $activityItems,
                        allowedContentTypes: [.pdf, .png, .jpeg],
                        maxFileSize: maxFileSize,
                        maxTotalSize: maxTotalSize,
                        alertMessage: $alertMessage,
                        showAlert: $showAlert)
           }
           .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
           }
            
            Button(isInExportMode ? "Quit Export Mode" : "Export Mode") {
                isInExportMode.toggle()
            }
            .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))

            Button("Upload From Camera") {
                showingPicker = true
            }
            .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
//            Button("Upload from Photo Album") {
//                sourceType = .photoLibrary
//                showingPicker = true
//            }
            .sheet(isPresented: $showingPicker) {
                CameraPicker(image: $image,
                        profile: userProfile,
                        selectedDocuments: $activityItems,
                        alertMessage: $alertMessage,
                        showAlert: $showAlert,
                        sourceType: sourceType)
            }
            .id(refreshID)
        }
        .onAppear{
                    refreshID = UUID() // Change the ID to force update
                }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [URL]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        // No update action needed
    }
}

struct DocumentRow: View {
    var document: Document
    @State var forceUpdate = false
    @Binding var isInExportMode: Bool
    @Binding var selectedExportDocuments: Set<Document.ID>
    
    var body: some View {
        HStack {
            if isInExportMode {
                Image(systemName: selectedExportDocuments.contains(document.id) ? "checkmark.circle.fill" : "circle")
                    .onTapGesture {
                        toggleSelection(for: document)
                    }
            }
            Text(document.fileName ?? "Unknown")
                .lineLimit(1)
            Spacer()
            if !isInExportMode {
                NavigationLink(destination: DocumentDetailView(document: document)) {
                }
            }
        }
        .onAppear {
            self.forceUpdate.toggle()  // Toggle to refresh view
        }
    }
    
    private func toggleSelection(for document: Document) {
        guard let id = document.id else { return }
        if selectedExportDocuments.contains(id) {
            selectedExportDocuments.remove(id)
        } else if selectedExportDocuments.count < 5 {
            selectedExportDocuments.insert(id)
        }
    }
}

struct DocumentDetailView: View {
    @ObservedObject var document: Document
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newName: String = ""
    @State private var isEditing: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            if isEditing {
                TextField("Enter new name", text: $newName)
                Button("Save") {
                    if newName.count > 100 {
                        alertMessage = "File name cannot exceed 100 characters."
                        showAlert = true
                        return
                    }
                    let fullName = newName + (document.fileExtension ?? "")
                    document.fileName = fullName  // Preserve original file extension
                    do {
                        try viewContext.save()

                    } catch {
                        print("Failed to save document: \(error)")
                    }
                    isEditing = false
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
            } else {
                Text(document.fileName ?? "Unknown Document")
                Button("Rename") {
                    // Remove the extension before editing
                    newName = document.baseFileName
                    isEditing = true
                }
                .buttonStyle(PressableButtonStyle(defaultColor: .cBlue, pressedColor: .cCloud, height: 7, width: 340))
            }
            
            // Display the appropriate viewer based on file type
            if let fileData = document.fileData, let fileName = document.fileName {
                if fileName.hasSuffix(".pdf") {
                    PDFViewer(data: fileData)
                } else if fileName.hasSuffix(".png") || fileName.hasSuffix(".jpeg") {
                    ZoomableImageView(imageData: fileData)
                } else {
                    Text("File format not supported for preview")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .padding()
        .navigationTitle("Document Details")
    }
}

extension Document {
    var baseFileName: String {
        return (fileName?.components(separatedBy: ".").dropLast().joined(separator: ".")) ?? ""
    }

    var fileExtension: String? {
        return (fileName?.components(separatedBy: ".").last).map { ".\($0)" }
    }
}


struct PDFViewer: UIViewRepresentable {
    var data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {}
}

struct ZoomableImageView: UIViewRepresentable {
    var imageData: Data

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 6.0
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(data: imageData)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // This function can be used to update the view with new data
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ZoomableImageView
        weak var imageView: UIImageView?

        init(_ parent: ZoomableImageView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
    }
    
    
}
