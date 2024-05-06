//
//  AddProfileView.swift
//  HestiaHub
//
//  Created by 朱麟凱 on 4/29/24.
//
import Foundation
import CoreData
import Combine

enum AlertType: Identifiable {
    case missingInfo
    case incorrectInput(String)
    
    var id: Int {
        switch self {
        case .missingInfo:
            return 0
        case .incorrectInput:
            return 1
        }
    }
    
    var title: String {
        switch self {
        case .missingInfo:
            return "Missing Information"
        case .incorrectInput:
            return "Wrong Input"
        }
    }
    
    var message: String {
        switch self {
        case .missingInfo:
            return "Please fill in all the required fields."
        case .incorrectInput(let message):
            return message
        }
    }
}


class AddProfileViewModel: ObservableObject {
    @Published var profileName: String = ""
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var alertType: AlertType?
    @Published var age: Int16 = 0
    @Published var dateOfBirth: Date = Date()
    @Published var bloodType: String = "A" // Default relationship
    @Published var bloodTypes: [String] = ["A", "B", "O", "AB"]
    @Published var relationship: String = "User" // Default relationship
    @Published var relationships: [String] = ["User", "Parent", "Kid", "Friend", "Relative", "Grandparent", "Grandchild"]
    @Published var deceased: String = "No"
    @Published var deceasedStatus: [String] = ["No", "Yes"]
    @Published var sex: String = "-"
    @Published var sexOption: [String] = ["-", "Female", "Male"]
    @Published var dateOfDeath: Date = Date()
    @Published var death: String = ""
    @Published var showHWAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var showFillingAlert: Bool = false
    @Published var pastSurgeries: String = ""
    @Published var ongoingTreatments: String = ""
    @Published var healthConditions: String = ""
    @Published var allergies: String = ""
    
    let minWeight = 1
    let maxWeight = 500
    let minHeight = 30
    let maxHeight = 300
    
    func validateFields() -> Bool {
        // Assuming weight and height are Strings and need to be converted to Int
        if let weightValue = Int16(weight), weightValue >= minWeight, weightValue <= maxWeight {
            // Weight is valid, now check height
            if let heightValue = Int16(height), heightValue >= minHeight, heightValue <= maxHeight {
                // Both height and weight are valid
                alertType = nil
                return true
            } else {
                // Height is invalid
                alertType = .incorrectInput("Please enter a height between \(minHeight) and \(maxHeight) cm.")
            }
        } else {
            // Weight is invalid
            alertType = .incorrectInput("Please enter a weight between \(minWeight) and \(maxWeight) kg.")
        }
        return false
    }


    
    // This function tries to save a new profile, if successful, it returns the new profile, otherwise returns nil.
    func saveNewProfile(context: NSManagedObjectContext) -> Profiles? {
        // Check for filling all required fields
        if profileName.isEmpty {
            alertType = .missingInfo
            return nil
        }
        if Int16(calculateAge(from: dateOfBirth, dateOfDeath: Date())) > 120 && deceased == "No"{
            alertType = .incorrectInput("Please enter an age under 120 year-old.")
            return nil
        }
        // Validate fields and proceed if they are correct
        if validateFields() {
            let newProfile = Profiles(context: context)
            newProfile.profileName = profileName
            newProfile.bloodType = bloodType
            newProfile.relationship = relationship
            newProfile.weight = Int16(weight) ?? 1
            newProfile.height = Int16(height) ?? 30
            newProfile.deceased = deceased
            newProfile.dateOfDeath = dateOfDeath
            newProfile.reasonOfDeath = death
            newProfile.dateOfBirth = dateOfBirth
            newProfile.id = UUID()
            newProfile.age = Int16(calculateAge(from: dateOfBirth, dateOfDeath: Date()))
            newProfile.dateOfCreation = Date()
            newProfile.sex = sex
            
            newProfile.pastSurgeries = pastSurgeries
            newProfile.ongoingTreatments = ongoingTreatments
            newProfile.healthConditions = healthConditions
            newProfile.allergies = allergies

            do {
                try context.save()
                return newProfile
            } catch {
                print("Failed to save profile: \(error)")
                alertType = .incorrectInput("Error saving profile. Please try again.")
                return nil
            }
        }
        return nil
    }
        
}

func calculateAge(from dateOfBirth: Date, dateOfDeath: Date) -> Int {
    let currentDate = Date()  // Capture the current date
    let deathDate = dateOfDeath >= currentDate ? currentDate : dateOfDeath  // Use current date if death date is in the future
    let calendar = Calendar.current

    let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: deathDate)
    return ageComponents.year ?? 0  // Safely unwrap and return the age or 0 if something goes wrong
}



