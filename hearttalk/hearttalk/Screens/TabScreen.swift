//
//  TabScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 05.02.2025.
//


import SwiftUI

struct TabScreen: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @State private var requestManager: RequestManager = RequestManager.shared
    
    @State private var tab: TabType = .home
    
    @State private var isShowCreateCard: Bool = false
    @State private var isShowCreatePack: Bool = false
    @State private var isShowOnlineCreateCard: Bool = false
    @State private var isShowOnlineCreatePack: Bool = false
    @State private var isShowDailyCard: Bool = false
    @State private var isShowGlobalAlert: Bool = false
    @State private var isShowAgeAlert: Bool = false
    @State private var isShowImportCards: Bool = false
    @State private var isShowGenerateCards: Bool = false
    
    var body: some View {
        makeContent()
            .background(
                Color.lightBlack
                    .ignoresSafeArea()
            )
            .onAppear {
                if viewModel.isOnline && onlineViewModel.isSignedIn && requestManager.isConnected {
                    setUserOnline()
                }
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
            .onChange(of: requestManager.isConnected) { newValue in
                guard !newValue else { return }
                viewModel.isOnline = false
            }
            .onChange(of: viewModel.isOnline) { newValue in
                if onlineViewModel.isSignedIn && requestManager.isConnected {
                    if viewModel.isOnline {
                        setUserOnline()
                    }
                }
                if newValue {
                    if onlineViewModel.isSignedIn {
                        onlineViewModel.fetchAll()
                    }
                }
                guard !newValue else { return }
                tab = .settings
            }
            .onChange(of: tab) { _ in
                HapticManager.shared.triggerHapticFeedback(.soft)
                SoundManager.shared.sound(.card)
            }
            .fullScreenCover(isPresented: $isShowCreateCard) {
                CreateCardScreen()
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $isShowCreatePack) {
                CreatePackScreen()
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $isShowImportCards) {
                ImportCardsScreen()
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $isShowGenerateCards) {
                GenerateCardsScreen()
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $isShowDailyCard) {
                Questions(card: viewModel.dailyOriginalCard)
                    .environmentObject(viewModel)
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(isPresented: $isShowOnlineCreateCard) {
                OnlineCreateCardScreen()
                    .environmentObject(onlineViewModel)
            }
            .fullScreenCover(isPresented: $isShowOnlineCreatePack) {
                OnlineCreatePackScreen()
                    .environmentObject(onlineViewModel)
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
                        tab = .settings
                    }
                }
            }
            .alert(isPresented: $isShowGlobalAlert) {
                Alert(title: Text(viewModel.remoteConfigManager.appData?.alertTitle ?? ""), message: Text(viewModel.remoteConfigManager.appData?.alertMessage ?? ""), dismissButton: .default(Text(Localization.confirm), action: {}))
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 0) {
            switch tab {
            case .home:
                HomeScreen()
                    .environmentObject(viewModel)
                    .environmentObject(onlineViewModel)
            case .search:
                OnlineScreen()
                    .environmentObject(viewModel)
                    .environmentObject(onlineViewModel)
            case .add:
                EmptyView()
            case .profile:
                ProfileScreen()
                    .environmentObject(viewModel)
                    .environmentObject(onlineViewModel)
            case .settings:
                Settings()
                    .environmentObject(viewModel)
            }
            HStack {
                ForEach(formatedTabs()) { type in
                    if type == .add {
                        Menu {
                            if tab == .home || tab == .settings {
                                Button(Localization.addCard) {
                                    isShowCreateCard.toggle()
                                }
                                Button(Localization.addPack) {
                                    isShowCreatePack.toggle()
                                }
                                Button(Localization.importCards) {
                                    isShowImportCards.toggle()
                                }
                                Button(Localization.generateAI) {
                                    isShowGenerateCards.toggle()
                                }
                            } else {
                                Button(Localization.addCard) {
                                    isShowOnlineCreateCard.toggle()
                                }
                                Button(Localization.addPack) {
                                    isShowOnlineCreatePack.toggle()
                                }
                            }
                        } label: {
                            Icon(name: type.imageName, size: .custom(20), color: .darkWhite)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Button {
                            tab = type
                        } label: {
                            Icon(name: type.imageName, size: .custom(20), color: .darkWhite.opacity(type == tab ? 1 : 0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.bottom, (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 30) / 2)
            .background(
                Rectangle()
                    .fill(.lightBlack)
            )
        }
    }
    
    private func formatedTabs() -> [TabType] {
        if viewModel.isOnline && requestManager.isConnected {
            TabType.allCases
        } else {
            TabType.offlineAllCases
        }
    }
    
}
