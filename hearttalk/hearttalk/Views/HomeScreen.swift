
import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @State private var requestManager: RequestManager = RequestManager()
    
    @State private var isShowSettings: Bool = false
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    @State private var isShowDailyCard: Bool = false
    @State private var isShowGlobalAlert: Bool = false
    @State private var isShowOnlineScreen: Bool = false
    @State private var isShowAgeAlert: Bool = false
    
    @State private var selectedPack: Pack?
    @State private var selectedNamePack: Pack?
    @State private var selectedDescPack: Pack?
    
    var body: some View {
        NavigationView {
            makeContent()
                .background(.lightBlack)
        }
        .onAppear {
            isShowGlobalAlert = (viewModel.remoteConfigManager.appData?.isShowAlert) ?? false
            if let action = QuickActionsManager.shared.quickAction {
                switch action {
                case .addCard:
                    isShowCreateCard.toggle()
                case .addPack:
                    isShowCreatePack.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $isShowSettings) {
            Settings()
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowCreateCard) {
            CreateCardScreen()
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowCreatePack) {
            CreatePackScreen()
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowDailyCard) {
            Questions(card: viewModel.dailyOriginalCard)
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $isShowOnlineScreen) {
            OnlineScreen()
                .environmentObject(viewModel)
        }
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
        .alert(isPresented: $isShowAgeAlert) {
            Alert(title: Text(Localization.adultAlertTitle), message: Text(Localization.adultAlertMessage), primaryButton: .default(Text(Localization.confirm), action: {
                UserDefaultsManager.shared.isShowAgeAlert = false
            }), secondaryButton: .cancel(Text(Localization.cancel), action: {}))
        }
        .onOpenURL { url in
            if url.scheme == "hearttalk" {
                if url.host == "createScreen" {
                    isShowCreateCard.toggle()
                }
                if url.host == "dailyWidgetOpen" {
                    isShowDailyCard.toggle()
                }
                if url.host == "dailyTurningOn" {
                    if !isShowSettings {
                        isShowSettings.toggle()
                    }
                }
            }
        }
        .alert(isPresented: $isShowGlobalAlert) {
            Alert(title: Text(viewModel.remoteConfigManager.appData?.alertTitle ?? ""), message: Text(viewModel.remoteConfigManager.appData?.alertMessage ?? ""), dismissButton: .default(Text(Localization.confirm), action: {}))
        }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            HomeTopBar(text: "Home") {
                isShowSettings.toggle()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    makeSection("My content", isCreatable: true) {
                        makeMyFeed()
                    }
                    makeSection("Our choice") {
                        makeHTFeed()
                    }
                    makeSection("Flip cards") {
                        makeQuizFeed()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeMyFeed() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(viewModel.myPacks) { pack in
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
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
                        Button(role: .destructive) {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            viewModel.deletePack(pack)
                        } label: {
                            Text("Delete")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedNamePack = pack
                        } label: {
                            Text("Change name")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedDescPack = pack
                        } label: {
                            Text("Change description")
                        }
                    }
                    .fullScreenCover(item: $selectedPack) { pack in
                        Questions(pack: selectedPack ?? pack)
                            .environmentObject(viewModel)
                            .navigationBarHidden(true)
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
                ForEach(viewModel.htPacks) { pack in
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
                            Text("Delete")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedNamePack = pack
                        } label: {
                            Text("Change name")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedDescPack = pack
                        } label: {
                            Text("Change description")
                        }
                    }
                    .fullScreenCover(item: $selectedPack) { pack in
                        Questions(pack: selectedPack ?? pack)
                            .environmentObject(viewModel)
                            .navigationBarHidden(true)
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
                ForEach(viewModel.quizPacks) { pack in
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
                            Text("Delete")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedNamePack = pack
                        } label: {
                            Text("Change name")
                        }
                        Button {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            selectedDescPack = pack
                        } label: {
                            Text("Change description")
                        }
                    }
                    .fullScreenCover(item: $selectedPack) { pack in
                        Questions(pack: selectedPack ?? pack)
                            .environmentObject(viewModel)
                            .navigationBarHidden(true)
                    }
                }
            }
            .padding(.leading, 20)
        }
    }
    
    @ViewBuilder
    private func makeSection<Content: View>(_ text: String, isCreatable: Bool = false, content: () -> Content) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.darkWhite)
                Spacer()
                if isCreatable {
                    Menu {
                        Button("Add card") {
                            isShowCreateCard.toggle()
                        }
                        Button("Add pack") {
                            isShowCreatePack.toggle()
                        }
                    } label: {
                        Icon(name: "add")
                    }
                }
            }
            .padding(.horizontal, 20)
            content()
                .frame(height: 140)
        }
    }
    
}
