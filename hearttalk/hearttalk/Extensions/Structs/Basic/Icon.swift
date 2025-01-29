//
//  Icon.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct Icon: View {
    
    var name: String
    var size: SizeType = .def
    var color: Color = .darkWhite
    var renderingMode: Image.TemplateRenderingMode = .template
    
    enum SizeType {
        case def
        case custom(CGFloat)
        case full(w: CGFloat, h: CGFloat)
    }
    
    var body: some View {
        var width: CGFloat = 24
        var height: CGFloat = 24
        switch size {
        case .def:
            width = 24
            height = 24
        case .custom(let num):
            width = num
            height = num
        case .full(let w, let h):
            width = w
            height = h
        }
        return Image(name)
            .renderingMode(renderingMode)
            .resizable()
            .foregroundStyle(color)
            .frame(width: width, height: height)
    }
    
}
