import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct DocumentPicker: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    var profile: Profiles
    @Binding var selectedDocuments: [URL]
    var allowedContentTypes: [UTType]
    let maxFileSize: Int  // Maximum file size allowed (10 MB)
    let maxTotalSize: Int  // Maximum total size allowed (50 MB)
    @Binding var alertMessage: String  // Bind a string for alert messages
    @Binding var showAlert: Bool  // Bind a boolean to control alert visibility

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewContext: viewContext, profile: profile, maxFileSize: maxFileSize, maxTotalSize: maxTotalSize)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        var parent: DocumentPicker
        var viewContext: NSManagedObjectContext
        var profile: Profiles
        var maxFileSize: Int
        var maxTotalSize: Int
        var totalSize = 0  // Keep track of the total file size selected

        init(_ documentPicker: DocumentPicker, viewContext: NSManagedObjectContext, profile: Profiles, maxFileSize: Int, maxTotalSize: Int) {
            self.parent = documentPicker
            self.viewContext = viewContext
            self.profile = profile
            self.maxFileSize = maxFileSize
            self.maxTotalSize = maxTotalSize
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var tempTotalSize = 0
            parent.selectedDocuments = urls.compactMap { url -> URL? in
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attributes[.size] as? Int ?? 0
                    
                    if fileSize > parent.maxFileSize {
                        DispatchQueue.main.async { [self] in
                            self.parent.alertMessage = "One or more files exceed the maximum file size of 10 MB."
                            self.parent.showAlert = true
                        }
                        return nil
                    }
                    
                    tempTotalSize += fileSize
                    if tempTotalSize > parent.maxTotalSize {
                        DispatchQueue.main.async {
                            self.parent.alertMessage = "Total file size exceeds the maximum limit of 50 MB."
                            self.parent.showAlert = true
                        }
                        return nil
                    }

                    let fileData = try Data(contentsOf: url)
                    let document = Document(context: viewContext)
                    document.profileID = profile.id
                    document.fileName = url.lastPathComponent
                    document.fileData = fileData
                    document.id = UUID()

                    return url
                } catch {
                    print("Error processing file data: \(error)")
                    return nil
                }
            }
            
            if tempTotalSize <= parent.maxTotalSize {
                do {
                    try viewContext.save()
                } catch {
                    print("Error saving documents: \(error)")
                }
            }
        }
    }
}
