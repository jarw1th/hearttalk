//
//  RoomsScreen.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 02.02.2025.
//


import SwiftUI

struct RoomsScreen: View {
    
    @EnvironmentObject var onlineViewModel: OnlineViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowSignScreen: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onAppear {
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                }
            }
            .onChange(of: onlineViewModel.isSignedIn) { newValue in
                if !newValue {
                    isShowSignScreen.toggle()
                }
            }
            .onChange(of: onlineViewModel.needToUpdate) { value in
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                }
            }
            .fullScreenCover(isPresented: $isShowSignScreen) {
                SignScreen()
                    .environmentObject(onlineViewModel)
            }
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        if onlineViewModel.isSignedIn {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 40) {
                    SearchBar(placeholder: Localization.onlineSearch, text: $searchText)
                        .padding(.horizontal, 20)
                    
                    if onlineViewModel.isLoading {
                        LoadingView(isLarge: false)
                    } else {
                        
                    }
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                if onlineViewModel.isSignedIn {
                    onlineViewModel.fetchAll()
                }
            }
        } else {
            VStack {
                Spacer()
                LoginButton {
                    isShowSignScreen = true
                }
                .padding(60)
                Spacer()
            }
        }
    }
    
}
