//struct DocumentsView: View {
//    let maxFileSize = 10 * 1024 * 1024  // 10 MB in bytes
//    let maxTotalSize = 50 * 1024 * 1024  // 50 MB in bytes
//    @ObservedObject var userProfile: Profiles
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest var documents: FetchedResults<Document>
//    @State private var showingDocumentPicker = false
//    @State private var selectedExportDocuments = Set<Document.ID>()
//    @State private var showingShareSheet = false
//    @State private var activityItems: [URL] = []
//    @State private var isInExportMode = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//    let maxExportLimit = 5  // Maximum number of documents that can be selected for export
//
//    init(userProfile: Profiles) {
//        self.userProfile = userProfile
//        
//        // Safely unwrapping `userProfile.id`
//        if let profileID = userProfile.id {
//            self._documents = FetchRequest<Document>(
//                entity: Document.entity(),
//                sortDescriptors: [NSSortDescriptor(keyPath: \Document.fileName, ascending: true)],
//                predicate: NSPredicate(format: "profileID == %@", profileID as CVarArg)
//            )
//        } else {
//            // Handle the case where `id` is `nil` by setting up a fetch request that will not return any results.
//            self._documents = FetchRequest<Document>(
//                entity: Document.entity(),
//                sortDescriptors: [NSSortDescriptor(keyPath: \Document.fileName, ascending: true)],
//                predicate: NSPredicate(format: "1 == 0")
//            )
//        }
//    }
//
//
//    var body: some View {
//        VStack {
//            VStack {
//                Button("Upload Documents") {
//                    showingDocumentPicker = true
//                }
//                .sheet(isPresented: $showingDocumentPicker) {
//                    DocumentPicker(profile: userProfile,
//                                   selectedDocuments: $activityItems,
//                                   allowedContentTypes: [.pdf, .png, .jpeg],
//                                   maxFileSize: maxFileSize,
//                                   maxTotalSize: maxTotalSize,
//                                   alertMessage: $alertMessage,
//                                   showAlert: $showAlert)
//                }
//                .alert(isPresented: $showAlert) {
//                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//                }
//                
//                if isInExportMode {
//                    Button("Close Export") {
//                        isInExportMode.toggle()
//                    }
//                } else {
//                    Button("Export Documents") {
//                        isInExportMode.toggle()
//                    }
//                }
//
//                List {
//                    ForEach(documents, id: \.self) { document in
//                        if isInExportMode {
//                            MultipleSelectionRow(document: document, isSelected: selectedExportDocuments.contains(document.id)) {
//                                                toggleSelection(for: document)
//                            }
//                        } else {
//                            NavigationLink(destination: DocumentDetailView(document: document)) {
//                                Text(document.fileName ?? "Unknown")
//                            }
//                        }
//                    }
//                    .onDelete(perform: deleteDocuments)
//                }
//                
//                if isInExportMode {
//                    Button("Export Selected") {
//                        exportDocuments()
//                    }
//                    .disabled(selectedExportDocuments.isEmpty)
//                }
//            }
//            .padding()
//            .navigationTitle("Documents")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    if isInExportMode {
//                        Button("Done") {
//                            isInExportMode = false
//                            selectedExportDocuments.removeAll()
//                        }
//                    }
//                }
//            }
//            .sheet(isPresented: $showingShareSheet) {
//                ActivityView(activityItems: activityItems)
//            }
//        }
//    }
//    
//    private func toggleSelection(for document: Document) {
//        guard let id = document.id else {
//            print("Document ID is nil")
//            return
//        }
//        if selectedExportDocuments.contains(id) {
//            selectedExportDocuments.remove(id)
//            print("Deselected \(id)")
//        } else if selectedExportDocuments.count < maxExportLimit {
//            selectedExportDocuments.insert(id)
//            print("Selected \(id)")
//        } else {
//            print("Selection limit reached")
//        }
//        print("Current selections: \(selectedExportDocuments)")
//    }
//    
//    private func exportDocuments() {
//        let documentsToExport = documents.filter { selectedExportDocuments.contains($0.id) }.compactMap { document -> URL? in
//            guard let data = document.fileData else { return nil }
//            let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(document.fileName ?? "temp.pdf")
//            do {
//                try data.write(to: tmpURL)
//                return tmpURL
//            } catch {
//                print("Failed to write file data for export: \(error)")
//                return nil
//            }
//        }
//        if !documentsToExport.isEmpty {
//            activityItems = documentsToExport
//            showingShareSheet = true
//            selectedExportDocuments.removeAll()  // Clear selections after export
//            isInExportMode = false  // Reset export mode after sharing
//        }
//    }
//    
//    private func deleteDocuments(at offsets: IndexSet) {
//        for index in offsets {
//            let document = documents[index]
//            viewContext.delete(document)
//        }
//        
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error saving context after deleting documents: \(error)")
//        }
//    }
//}
//
//struct MultipleSelectionRow: View {
//    var document: Document
//    var isSelected: Bool
//    var action: () -> Void
//
//    var body: some View {
//        HStack {
//            Text(document.fileName ?? "Unknown")
//            Spacer()
//            if isSelected {
//                Image(systemName: "checkmark")
//            }
//        }
//        .contentShape(Rectangle())
//        .onTapGesture(perform: action)
//    }
//}
//
//struct ActivityView: UIViewControllerRepresentable {
//    var activityItems: [URL]
//    var applicationActivities: [UIActivity]? = nil
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
//        // No update action needed
//    }
//}
//
//struct DocumentDetailView: View {
//    @ObservedObject var document: Document
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var newName: String = ""
//    @State private var isEditing: Bool = false
//
//    var body: some View {
//        VStack {
//            if isEditing {
//                TextField("Enter new name", text: $newName)
//                Button("Save") {
//                    document.fileName = newName
//                    try? viewContext.save()
//                    isEditing = false
//                }
//            } else {
//                Text(document.fileName ?? "Unknown Document")
//                Button("Rename") {
//                    newName = document.fileName ?? ""
//                    isEditing = true
//                }
//            }
//            
//            // Determine how to display the document based on its type
//            if let fileData = document.fileData, document.fileName?.hasSuffix(".pdf") == true {
//                PDFViewer(data: fileData)
//            } else if let fileData = document.fileData, document.fileName?.hasSuffix(".png") == true {
//                ImageViewer(data: fileData)
//            } else {
//                Text("File format not supported for preview")
//            }
//        }
//        .padding()
//        .navigationTitle("Document Details")
//    }
//}
//
//struct PDFViewer: UIViewRepresentable {
//    var data: Data
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.autoScales = true
//        pdfView.document = PDFDocument(data: data)
//        return pdfView
//    }
//
//    func updateUIView(_ pdfView: PDFView, context: Context) {
//        // Update the view if required.
//    }
//}
//
//struct ImageViewer: View {
//    var data: Data
//
//    var body: some View {
//        if let uiImage = UIImage(data: data) {
//            Image(uiImage: uiImage)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//        } else {
//            Text("Unable to load image")
//        }
//    }
//}
