import SwiftUI
import CoreData

struct ProfileListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddProfileView = false // State to control navigation

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Profiles.profileName, ascending: true)],
        animation: .default)
    private var profiles: FetchedResults<Profiles>

    var body: some View {
            NavigationView {
                List {
                    ForEach(profiles) { profile in
                        NavigationLink {
                            ProfileDetailView(userProfile: profile)
                        } label: {
                            Text(profile.profileName!)
                                .padding()  // Add padding to each row for better visual appeal
                                .background(Color.cBlue)  // Apply background color to each row
                                .cornerRadius(5)  // Optional: add rounded corners to each row
                                .foregroundColor(Color.cDaisy2)
                               
                        }
                        .padding()  // Add padding to each row for better visual appeal
                        .background(Color.cBlue)  // Apply background color to each row
                        .cornerRadius(10)  // Optional: add rounded corners to each row
                        .foregroundColor(.white)
                    }
                    .onDelete(perform: deleteprofiles)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Profiles")
                .foregroundColor(Color.cDaisy2)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                            .foregroundColor(Color.cDaisy2)
                    }
                    ToolbarItem {
                        Button(action: {showingAddProfileView = true}) {
                            Label("Add profile", systemImage: "plus")
                        }
                        .buttonStyle(CircleButtonStyle(fillColor: Color.cBlue))
                    }
                }
                .foregroundColor(Color.cDaisy2)
                .sheet(isPresented: $showingAddProfileView) {
                    // Present the AddProfileView as a modal sheet
                    AddProfileView() // Make sure to pass any required parameters to your AddProfileView initializer
                        .environment(\.managedObjectContext, viewContext)
                }
                Text("Select an profile")
                
            }
        }
    
    struct CircleButtonStyle: ButtonStyle {
        var fillColor: Color = .blue
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(10)
                .background(fillColor)
                .foregroundColor(.white)
                .clipShape(Circle())
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }
    
    private func addprofile() {
        withAnimation {
            let newprofile = Profiles(context: viewContext)
            newprofile.profileName = ""
            newprofile.id = UUID()
            newprofile.dateOfBirth = Date()
            newprofile.dateOfCreation = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteprofiles(offsets: IndexSet) {
        withAnimation {
            offsets.map { profiles[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let profileFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ProfileListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
