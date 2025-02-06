
import SwiftUI

struct NotesScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    let card: Card?
    
    @State private var height: CGFloat = 0
    
    @State private var isEdit: Bool = false
    @State private var isShowCreateNote: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                viewModel.fetchNotes(forCardId: card?.id ?? "")
                viewModel.noteIndex = 0
            }
            .fullScreenCover(isPresented: $isShowCreateNote) {
                CreateNoteScreen()
                    .environmentObject(viewModel)
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 40 : 32) {
            BackTopBar(text: Localization.notes, isEdit: isEdit, isSelected: viewModel.selectedNotes == viewModel.notes) {
                if viewModel.selectedNotes != viewModel.notes {
                    viewModel.selectedNotes = viewModel.notes
                } else {
                    viewModel.selectedNotes = []
                }
            } deleteTapAction: {
                if let card {
                    viewModel.deleteNotes(for: card)
                }
            } optionButtons: {
                VStack {
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        isShowCreateNote.toggle()
                    } label: {
                        Text(Localization.addNew)
                    }
                    Button(role: .destructive) {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        isEdit.toggle()
                    } label: {
                        Text(Localization.delete)
                    }
                }
            } closeTapAction: {
                if isEdit {
                    isEdit = false
                } else {
                    dismiss()
                }
            }
            .padding(.vertical, 16)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    ForEach(Array(viewModel.notes.enumerated()), id: \.element.id) { index, note in
                        VStack(spacing: 16) {
                            TextNoteView(text: note.text, isSelected: isEdit ? viewModel.selectedNotes.contains(note) : true) {
                                guard isEdit else { return }
                                if viewModel.selectedNotes.contains(note) {
                                    viewModel.selectedNotes.removeAll(where: { $0 == note })
                                } else {
                                    viewModel.selectedNotes.append(note)
                                }
                            }
                            if let imageData = note.imageData,
                               let image = UIImage(data: imageData) {
                                ImageNoteView(image: image, isSelected: isEdit ? viewModel.selectedNotes.contains(note) : true) {
                                    guard isEdit else { return }
                                    if viewModel.selectedNotes.contains(note) {
                                        viewModel.selectedNotes.removeAll(where: { $0 == note })
                                    } else {
                                        viewModel.selectedNotes.append(note)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
}
