import SwiftUI
import UIKit
import CoreData
import UniformTypeIdentifiers

enum PickerSourceType {
    case camera
    case photoLibrary
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    var profile: Profiles
    @Binding var selectedDocuments: [URL]
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    let maxFileSize: Int = 10_000_000  // 10 MB limit
    let maxTotalSize: Int = 50_000_000  // 50 MB limit
    var sourceType: PickerSourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        switch sourceType {
        case .camera:
            picker.sourceType = .camera
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.saveImage(image: image)  // Call saveImage to store the image locally
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }


    private func saveImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let fileSize = imageData.count
        
        if fileSize > maxFileSize {
            alertMessage = "The image exceeds the maximum file size of 10 MB."
            showAlert = true
            return
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString + ".jpeg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            selectedDocuments.append(fileURL)
            processDocument(at: fileURL)
        } catch {
            alertMessage = "Failed to save image: \(error.localizedDescription)"
            showAlert = true
        }
    }


    private func processDocument(at url: URL) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int ?? 0
            
            let fileData = try Data(contentsOf: url)
            let document = Document(context: viewContext)
            document.profileID = profile.id
            document.fileName = url.lastPathComponent
            document.fileData = fileData
            document.id = UUID()
            
            try viewContext.save()
        } catch {
            alertMessage = "Error processing file: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
