//
//  NoteDrawField.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct NoteDrawField: View {
    
    @State private var paths: [Path] = []
    
    private var uiPaths: [UIBezierPath] {
        paths.map { path -> UIBezierPath in
            let bezierPath = UIBezierPath()
            
            path.forEach { element in
                switch element {
                case .move(to: let point):
                    bezierPath.move(to: point)
                case .line(to: let point):
                    bezierPath.addLine(to: point)
                case .quadCurve(to: let point, control: let controlPoint):
                    bezierPath.addQuadCurve(to: point, controlPoint: controlPoint)
                case .curve(to: let point, control1: let controlPoint1, control2: let controlPoint2):
                    bezierPath.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                case .closeSubpath:
                    bezierPath.close()
                @unknown default:
                    break
                }
            }
            return bezierPath
        }
    }
        
    var onDrawComplete: (UIImage) -> Void
    
    var body: some View {
        ZStack {
            makeCanvas()
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        HapticManager.shared.triggerHapticFeedback(.light)
                        SoundManager.shared.sound(.click1)
                        paths.removeAll()
                    } label: {
                        Icon(name: "cross", size: .custom(20), color: .destruct)
                    }
                }
                Spacer()
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }
    
    @ViewBuilder
    private func makeCanvas() -> some View {
        Canvas { context, size in
            for path in paths {
                context.stroke(path, with: .color(.lightBlack), lineWidth: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.darkWhite)
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if paths.isEmpty || paths.last == nil {
                        var newPath = Path()
                        newPath.move(to: value.location)
                        paths.append(newPath)
                    } else if let last = paths.last, last.isEmpty {
                        paths[paths.count - 1].move(to: value.location)
                    } else {
                        paths[paths.count - 1].addLine(to: value.location)
                    }
                }
                .onEnded { _ in
                    DispatchQueue.main.async {
                        let image = getImage(size: CGSize(width: UIScreen.main.bounds.width - 40, height: 180))
                        onDrawComplete(image)
                    }
                    paths.append(Path())
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func getImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            UIColor.darkWhite.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            for path in uiPaths {
                UIColor.lightBlack.setStroke()
                path.lineWidth = 2
                path.stroke()
            }
        }
    }
    
}
