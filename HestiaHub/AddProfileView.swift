//
//  AddProfileView.swift
//  HestiaHub
//
//  Created by 朱麟凱 on 4/29/24.
//

import SwiftUI
import CoreData


struct AddProfileView: View {
    @StateObject var viewModel = AddProfileViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDetailForNewProfile: Bool = false
    @State private var newProfile: Profiles?
    
    @FetchRequest(
        entity: Profiles.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "relationship == %@", "User")
    ) var existingUserProfiles: FetchedResults<Profiles>

    private var relationships: [String] {
        if existingUserProfiles.isEmpty {
            return viewModel.relationships  // All relationships available
        } else {
            return viewModel.relationships.filter { $0 != "User" }  // Exclude 'User' if already used
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $viewModel.profileName)
                    Picker("Blood Type", selection: $viewModel.bloodType) {
                        ForEach(viewModel.bloodTypes, id: \.self) { bloodType in
                            Text(bloodType).tag(bloodType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.cBlue)
                    Picker("Sex", selection: $viewModel.sex) {
                        ForEach(viewModel.sexOption, id: \.self) { sex in
                            Text(sex).tag(sex)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.cBlue)
                    TextField("Weight", text: $viewModel.weight)
                    TextField("Height", text: $viewModel.height)
                    DatePicker(
                        "Date of Birth",
                        selection: $viewModel.dateOfBirth,
                        in: ...Date(), // Limits the date selection to the past
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(.cBlue)
                    Picker("Relationship", selection: $viewModel.relationship) {
                        ForEach(relationships, id: \.self) { relationship in
                            Text(relationship).tag(relationship)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.cBlue)
                    Picker("Deceased", selection: $viewModel.deceased) {
                        ForEach(viewModel.deceasedStatus, id: \.self) { deceased in
                            Text(deceased).tag(deceased)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.cBlue)
                    if viewModel.deceased == "Yes" {
                        DatePicker(
                            "Date of Death",
                            selection: $viewModel.dateOfDeath,
                            in: viewModel.dateOfBirth..., // Limits the date selection to the past
                            displayedComponents: .date
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(.cBlue)
                        TextField("Cause of Death", text: $viewModel.death)
                    }
                    
                }
                Section(header: Text("Additional Information")) {
                    TextField("Past Surgeries", text: $viewModel.pastSurgeries)
                    TextField("Ongoing Treatments", text: $viewModel.ongoingTreatments)
                    TextField("Health Conditions", text: $viewModel.healthConditions)
                    TextField("Allergies", text: $viewModel.allergies)
                }

            }
            
            .navigationTitle("Add Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss() // Dismiss the modal view
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        attemptToSaveProfile()
                    }
                }
            }
            .alert(item: $viewModel.alertType) { alertType in
                Alert(title: Text(alertType.title), message: Text(alertType.message), dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $showDetailForNewProfile) {
            if let newProfile = newProfile {
                ProfileDetailView(userProfile: newProfile)
            }
        }
    }
    
    private func attemptToSaveProfile() {
        if validateProfileName() && checkForDuplicate() {
            let profile = viewModel.saveNewProfile(context: viewContext)
            if profile != nil {
                self.newProfile = profile
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func checkForDuplicate() -> Bool {
        // Fetch request for all profiles
        let fetchRequest: NSFetchRequest<Profiles> = Profiles.fetchRequest()

        do {
            // Execute the fetch request to get all profiles
            let allProfiles = try viewContext.fetch(fetchRequest)

            // Print each profile's details
            for profile in allProfiles {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                print("Profile Name: \(profile.profileName ?? "N/A"), Date of Birth: \(dateFormatter.string(from: profile.dateOfBirth ?? Date()))")
            }

            // Create a calendar to extract year, month, and day components
            let calendar = Calendar.current

            // Extract components from the viewModel's dateOfBirth
            let components = calendar.dateComponents([.year, .month, .day], from: viewModel.dateOfBirth)
            if let dateOnly = calendar.date(from: components) {
                // Use the date with time stripped off for comparison
                fetchRequest.predicate = NSPredicate(format: "profileName == %@ AND dateOfBirth >= %@ AND dateOfBirth < %@", viewModel.profileName, dateOnly as CVarArg, calendar.date(byAdding: .day, value: 1, to: dateOnly)! as CVarArg)
            }

            let duplicateProfiles = try viewContext.fetch(fetchRequest)

            if duplicateProfiles.isEmpty {
                // No duplicates found, return true to continue
                return true
            } else {
                // Duplicates found, update alertType to inform the user
                viewModel.alertType = .incorrectInput("A profile with the same name and date of birth already exists.")
                return false
            }
        } catch {
            // Handle errors in fetching
            viewModel.alertType = .incorrectInput("Failed to check for duplicates due to an error: \(error.localizedDescription)")
            return false
        }
    }

    private func validateProfileName() -> Bool {
        // Split the profile name into components based on spaces to differentiate first name and last name
        let nameComponents = viewModel.profileName.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true).map(String.init)

        // Check if there are at least two components (first and last name)
        if nameComponents.count < 2 {
            viewModel.alertType = .incorrectInput("Please enter both first and last names.")
            return false
        }
        
        
        let firstName = nameComponents[0]
        let lastName = nameComponents[1]
        
        let regex = "^[a-zA-Z .-]+$"
        let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)

        if !regexTest.evaluate(with: firstName) || !regexTest.evaluate(with: lastName) {
            viewModel.alertType = .incorrectInput("Names can only contain letters, spaces, and dots.")
            return false
        }
        
        if !firstName.first!.isUppercase || !lastName.first!.isUppercase {
            viewModel.alertType = .incorrectInput("The first character of each name part must be uppercase.")
            return false
        }
        
        // Check the length of the first and last names
        if firstName.count < 2 || firstName.count > 35 || lastName.count < 2 || lastName.count > 35 {
            viewModel.alertType = .incorrectInput("Each name must be between 2 and 35 characters.")
            return false
        }

        // Total length check excluding spaces
        let totalLength = firstName.count + lastName.count
        if totalLength < 4 || totalLength > 70 {
            viewModel.alertType = .incorrectInput("Total name length must be between 4 and 70 characters.")
            return false
        }
        
        if nameComponents.count == 3 {
            let firstName = nameComponents[0]
            let middleName = nameComponents[1]
            let lastName = nameComponents[2]
            
            if !regexTest.evaluate(with: firstName) || !regexTest.evaluate(with: middleName) || !regexTest.evaluate(with: lastName) {
                viewModel.alertType = .incorrectInput("Names can only contain letters, spaces, and dots.")
                return false
            }
            
            if !firstName.first!.isUppercase ||  !middleName.first!.isUppercase || !lastName.first!.isUppercase {
                viewModel.alertType = .incorrectInput("The first character of each name part must be uppercase.")
                return false
            }
            
            // Check the length of the first and last names
            if firstName.count < 2 || firstName.count > 35 || middleName.count < 2 || middleName.count > 35 || lastName.count < 2 || lastName.count > 35 {
                viewModel.alertType = .incorrectInput("Each name must be between 2 and 35 characters.")
                return false
            }

            // Total length check excluding spaces
            let totalLength = firstName.count + middleName.count + lastName.count
            if totalLength < 6 || totalLength > 105 {
                viewModel.alertType = .incorrectInput("Total name length with middle name must be between 6 and 105 characters.")
                return false
            }
        }

        return true
    }
    
//    private func validateDateOfBirth() -> Bool {
//        if viewModel.dateOfBirth > Date() {
//            viewModel.alertType = .init(title: "Invalid Date", message: "Date of birth cannot be in the future.")
//            return false
//        }
//        return true
//    }
}

