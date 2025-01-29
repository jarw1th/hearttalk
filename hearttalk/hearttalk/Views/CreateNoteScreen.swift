
import SwiftUI
import PhotosUI

struct CreateNoteScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var text: String = ""
    @State private var image: UIImage?
    
    @State private var isShowAlert: Bool = false
    @State private var isShowImportImage: Bool = false
    @State private var isShowCropImage: Bool = false
    
    @State private var imageFromGallery: UIImage?
    
    private var configuration: PHPickerConfiguration {
        var conf = PHPickerConfiguration()
        conf.filter = .images
        conf.selectionLimit = 1
        return conf
    }
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
            .alert(isPresented: $isShowAlert) {
                Alert(title: Text(Localization.alert), message: Text("Note should be at least 10 characters long."), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
            .sheet(isPresented: $isShowImportImage) {
                PhotoPickerView(selectedImage: $imageFromGallery, configuration: configuration)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            SingleBackTopBar(text: "New note") {
                dismiss()
            }
            .padding(.vertical, 16)
            
            VStack(spacing: 24) {
                makeSection("Write something") {
                    NoteTextField(placeholder: "This question made me feel like...", text: $text)
                }
                makeSection(imageFromGallery != nil ? "Tap to edit" : "Draw something", isImage: true) {
                    VStack(spacing: 16) {
                        if let imageFromGallery {
                            NoteImageField(image: imageFromGallery) {
                                self.imageFromGallery = nil
                            } onChange: {
                                isShowImportImage.toggle()
                            } onCrop: {
                                isShowCropImage.toggle()
                            }
                        } else {
                            NoteDrawField { image in
                                self.image = image
                            }
                        }
                    }
                }
                Spacer()
                makeCreateButton()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    @ViewBuilder
    private func makeCreateButton() -> some View {
        Button {
            if checkText() {
                HapticManager.shared.triggerHapticFeedback(.light)
                SoundManager.shared.sound(.click1)
                createAction()
                dismiss()
            } else {
                isShowAlert.toggle()
            }
        } label: {
            Text(Localization.create)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
    private func checkText() -> Bool {
        text.count > 10
    }
    
    private func createAction() {
        let image = imageFromGallery ?? image
        viewModel.createNote(text: text, image: image)
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, isImage: Bool = false, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                Text("\(text)\(isImage && imageFromGallery == nil ? " or " : "")")
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                if isImage && imageFromGallery == nil {
                    Button {
                        isShowImportImage.toggle()
                    } label: {
                        Text("upload image")
                            .font(.custom("Poppins-Regular", size: 16))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.blue)
                    }
                }
                Spacer()
            }
            content()
        }
    }
    
}
