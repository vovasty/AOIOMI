//
//  ActivityIndicator.swift
//  AOIOMI
//
//  Created by vlsolome on 2/14/21.
//

import SwiftUI
// https://github.com/MojtabaHs/iActivityIndicator
// with Catalina fixes
private struct Arcs: View {
    @Binding private var isAnimating: Bool
    let count: UInt
    let width: CGFloat
    let spacing: CGFloat

    init(animate: Binding<Bool>, count: UInt, width: CGFloat, spacing: CGFloat) {
        _isAnimating = animate
        self.count = count
        self.width = width
        self.spacing = spacing
    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(0 ..< Int(count)) { index in
                Group {
                    item(forIndex: index, in: geometry.size)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                .animation(Animation
                    .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                    .repeatForever(autoreverses: false))
            }
        }
        .aspectRatio(contentMode: .fit)
        .onAppear {
            self.isAnimating = true
        }
    }

    private func item(forIndex index: Int, in geometrySize: CGSize) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: geometrySize.width / 2, y: geometrySize.height / 2),
                 radius: geometrySize.width / 2 - width / 2 - CGFloat(index) * (width + spacing),
                 startAngle: .degrees(0),
                 endAngle: .degrees(Double(Int.random(in: 120 ... 300))),
                 clockwise: true)
        return p.strokedPath(.init(lineWidth: width))
    }
}

struct ActivityIndicator: View {
    @State private var animate: Bool = false
    let count: UInt
    let width: CGFloat
    let spacing: CGFloat

    var body: some View {
        Arcs(
            animate: $animate,
            count: count,
            width: width,
            spacing: spacing
        )
        .onAppear { animate = true }
        .onDisappear { animate = false }
        .aspectRatio(contentMode: .fit)
    }
}

struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(count: 3, width: 2, spacing: 1)
            .foregroundColor(.green)
    }
}
