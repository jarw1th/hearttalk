
import SwiftUI

struct Notes: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    let card: Card?
    
    @State private var height: CGFloat = 0
    
    @State private var isSwipeBack: Bool = false
    @State private var isShowCreateNote: Bool = false
    @State private var isShowNotes: Bool = false
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                viewModel.fetchNotes(forCardId: card?.id ?? "")
                viewModel.noteIndex = 0
            }
    }
    
    private func makeContent() -> some View {
        VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
            HStack {
                if viewModel.noteIndex != 0 {
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.soft)
                        isSwipeBack.toggle()
                    } label: {
                        Image("swipeBack")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.darkWhite)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                    }
                }
                Spacer()
                makeBackButton()
            }
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
            
            NoteCardView(isSwipeBack: $isSwipeBack)
                .environmentObject(viewModel)
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image("cross")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48)
        }
    }
    
}
