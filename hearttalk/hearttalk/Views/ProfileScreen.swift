
import SwiftUI

struct ProfileScreen: View {
    
    @EnvironmentObject var viewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowCreatePack: Bool = false
    @State private var isShowCreateCard: Bool = false
    @State private var isShowSignOutAlert: Bool = false
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
                .edgesIgnoringSafeArea(.bottom)
                .sheet(isPresented: $isShowCreateCard) {
                    OnlineCreateScreen(createScreenType: .card)
                        .environmentObject(viewModel)
                }
                .sheet(isPresented: $isShowCreatePack) {
                    OnlineCreateScreen(createScreenType: .pack)
                        .environmentObject(viewModel)
                }
                .alert(isPresented: $isShowSignOutAlert) {
                    Alert(title: Text("Alert"), message: Text("You are going to sign out. Are you sure?"), primaryButton: .default(Text(Localization.confirm), action: {
                        viewModel.signOut()
                        dismiss()
                        viewModel.isSignedIn = false
                    }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
                }
                .onAppear {
                    viewModel.fetchPacks(viewModel.getUser()?.id ?? "")
                }
        }
    }
    
    private func makeContent() -> some View {
        VStack {
            HStack {
                Spacer()
                makeBackButton()
            }
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48) {
                if viewModel.isLoading {
                    Spacer()
                    LoadingView()
                    Spacer()
                } else {
                    HStack(spacing: 16) {
                        AsyncImage(url: viewModel.getUser()?.photoURL) { image in
                            image
                                .resizable()
                                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36)
                                .clipped()
                                .clipShape(Circle())
                        } placeholder: {
                            VStack {
                                Image("profile")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(.darkWhite)
                                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32, height: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32)
                            }
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36)
                        }
                        Text(viewModel.getUser()?.displayName ?? viewModel.getUser()?.email ?? "Unknown user")
                            .font(.custom("PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.darkWhite)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            isShowSignOutAlert.toggle()
                        } label: {
                            Text("Sign out")
                                .font(.custom("PlayfairDisplay-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                                .underline()
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.destruct)
                        }
                    }
                    makeList()
                }
            }
        }
        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 24 : 36)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 100)
    }
    
    private func makeList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 24) {
                AddHomeCard { type in
                    switch type {
                    case .pack:
                        isShowCreatePack.toggle()
                    case .card:
                        if !viewModel.packs.isEmpty {
                            isShowCreateCard.toggle()
                        }
                    }
                }
                ForEach(viewModel.packs.map({ $0.pack })) { pack in
                    OnlinePack(OnlinePackProperties(color: Color(hex: pack.color),
                                                    header: pack.name,
                                                    description: pack.text))
                    .contextMenu {
                        if pack.isCustom {
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                viewModel.deletePack(pack)
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            viewModel.fetchPacks(viewModel.getUser()?.id ?? "")
        }
    }
    
    private func makeBackButton() -> some View {
        Button {
            HapticManager.shared.triggerHapticFeedback(.light)
            SoundManager.shared.sound(.click1)
            dismiss()
        } label: {
            Image("cross")
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.darkWhite)
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48, height: UIDevice.current.userInterfaceIdiom == .phone ? 24 : 48)
        }
    }
    
}
