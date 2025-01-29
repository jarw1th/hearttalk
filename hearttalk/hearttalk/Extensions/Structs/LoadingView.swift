//
//  LoadingView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct LoadingView: View {
    
    var isLarge: Bool = true
    
    @State private var rotation: CGFloat = 0
    @State private var isAnimating: Bool = false
    
    var body: some View {
        makeLoader()
    }
    
    private func makeLoader() -> some View {
        ZStack {
            if isLarge {
                ZStack {
                    Image("heartLogoPart")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.darkWhite)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 200 : 400, height: UIDevice.current.userInterfaceIdiom == .phone ? 172 : 344)
                    
                    Image("hLogoPart")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(.lightBlack)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 54 : 106, height: UIDevice.current.userInterfaceIdiom == .phone ? 54 : 106)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            if !isAnimating {
                                startRotation()
                                isAnimating = true
                            }
                        }
                }
            } else {
                Image("hLogoPart")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.darkWhite)
                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 36 : 106, height: UIDevice.current.userInterfaceIdiom == .phone ? 36 : 106)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        if !isAnimating {
                            startRotation()
                            isAnimating = true
                        }
                    }
            }
        }
    }
    
    private func startRotation() {
        withAnimation(
            Animation.linear(duration: 1)
                .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }
    
}
