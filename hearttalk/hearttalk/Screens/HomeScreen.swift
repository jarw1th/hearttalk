
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @State private var requestManager: RequestManager = RequestManager.shared
    
    @State private var isShowAgeAlert: Bool = false
    @State private var searchText: String = ""
    
    @State private var selectedPack: Pack?
    @State private var selectedNamePack: Pack?
    @State private var selectedDescPack: Pack?
    
    var body: some View {
        makeContent()
            .background(
                Color.lightBlack
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
            )
            .fullScreenCover(item: $selectedNamePack) { pack in
                ChangeTextScreen(text: Binding(get: {
                    pack.name
                }, set: {
                    let p = Pack(id: pack.id, name: $0, text: pack.text)
                    viewModel.updatePack(p)
                }))
            }
            .fullScreenCover(item: $selectedDescPack) { pack in
                ChangeTextScreen(text: Binding(get: {
                    pack.text
                }, set: {
                    let p = Pack(id: pack.id, name: pack.name, text: $0)
                    viewModel.updatePack(p)
                }))
            }
            .fullScreenCover(item: $selectedPack) { pack in
                Questions(pack: pack)
                    .environmentObject(viewModel)
                    .environmentObject(onlineViewModel)
            }
            .alert(isPresented: $isShowAgeAlert) {
                Alert(title: Text(Localization.adultAlertTitle), message: Text(Localization.adultAlertMessage), primaryButton: .default(Text(Localization.confirm), action: {
                    UserDefaultsManager.shared.isShowAgeAlert = false
                }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 24) {
            TopBar(text: TabType.home.text)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    VStack(spacing: 24) {
                        makeSection(Localization.myContent) {
                            makeMyFeed()
                        }
                        if !viewModel.htPacks.isEmpty {
                            makeSection(Localization.ourChoice) {
                                makeHTFeed()
                            }
                        }
                        if !viewModel.quizPacks.isEmpty {
                            makeSection(Localization.flipCards) {
                                makeQuizFeed()
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    @ViewBuilder
    private func makeMyFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedMyPacks()) { pack in
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        guard selectedPack == nil else { return }
                        if pack.isAdult && UserDefaultsManager.shared.isShowAgeAlert {
                            isShowAgeAlert.toggle()
                        } else {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedPack = pack
                        }
                    } label: {
                        PackView(color: pack.color, name: pack.name, numberOfCards: pack.cards.count)
                    }
                    .contextMenu {
                        if !pack.isFavorite {
                            Button(role: .destructive) {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                viewModel.deletePack(pack)
                            } label: {
                                Text(Localization.delete)
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedNamePack = pack
                            } label: {
                                Text(Localization.changeName)
                            }
                            Button {
                                HapticManager.shared.triggerHapticFeedback(.light)
                                SoundManager.shared.sound(.click1)
                                selectedDescPack = pack
                            } label: {
                                Text(Localization.changeDescription)
                            }
                        }
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
    
    @ViewBuilder
    private func makeHTFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedOurChoice()) { pack in
                    Button {
                        selectedPack = pack
                    } label: {
                        PackView(color: pack.color, name: pack.name, numberOfCards: pack.cards.count)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            viewModel.deletePack(pack)
                        } label: {
                            Text(Localization.delete)
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedNamePack = pack
                        } label: {
                            Text(Localization.changeName)
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedDescPack = pack
                        } label: {
                            Text(Localization.changeDescription)
                        }
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
    
    @ViewBuilder
    private func makeQuizFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(formatedFlipPacks()) { pack in
                    Button {
                        selectedPack = pack
                    } label: {
                        PackView(color: pack.color, name: pack.name, numberOfCards: pack.cards.count)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            viewModel.deletePack(pack)
                        } label: {
                            Text(Localization.delete)
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedNamePack = pack
                        } label: {
                            Text(Localization.changeName)
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedDescPack = pack
                        } label: {
                            Text(Localization.changeDescription)
                        }
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
            }
            .padding(.horizontal, 20)
            content()
                .frame(height: 142)
        }
    }
    
    private func formatedMyPacks() -> [Pack] {
        if searchText.isEmpty {
            return viewModel.myPacks
        } else {
            return viewModel.myPacks.filter({ $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) || String($0.cards.count).contains(searchText.lowercased()) })
        }
    }
    
    private func formatedOurChoice() -> [Pack] {
        if searchText.isEmpty {
            return viewModel.htPacks
        } else {
            return viewModel.htPacks.filter({ $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) || String($0.cards.count).contains(searchText.lowercased()) })
        }
    }
    
    private func formatedFlipPacks() -> [Pack] {
        if searchText.isEmpty {
            return viewModel.quizPacks
        } else {
            return viewModel.quizPacks.filter({ $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) || String($0.cards.count).contains(searchText.lowercased()) })
        }
    }
    
}
