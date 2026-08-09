//import SwiftUI
//
//struct AnimatedCoachBackground: View {
//    @State private var animate = false
//
//    var body: some View {
//        GeometryReader { proxy in
//            ZStack {
//                LinearGradient(
//                    colors: [
//                        Color(red: 0.04, green: 0.06, blue: 0.07),
//                        Color(red: 0.06, green: 0.12, blue: 0.10),
//                        Color(red: 0.12, green: 0.08, blue: 0.15)
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//
//                ForEach(0..<7, id: \.self) { index in
//                    Circle()
//                        .stroke([Color.mint, .cyan, .orange, .pink][index % 4].opacity(0.13), lineWidth: 1.5)
//                        .frame(width: CGFloat(164 + index * 56), height: CGFloat(164 + index * 56))
//                        .rotationEffect(.degrees(animate ? Double(24 + index * 18) : Double(-18 - index * 12)))
//                        .scaleEffect(animate ? 1.08 : 0.92)
//                        .offset(
//                            x: animate ? CGFloat(index * 5) : CGFloat(index * -4),
//                            y: -proxy.size.height * 0.31 + (animate ? CGFloat(index * 3) : CGFloat(index * -2))
//                        )
//                        .animation(.easeInOut(duration: Double(5 + index)).repeatForever(autoreverses: true), value: animate)
//                }
//
//                LinearGradient(
//                    colors: [.clear, .black.opacity(0.5)],
//                    startPoint: .center,
//                    endPoint: .bottom
//                )
//            }
//            .ignoresSafeArea()
//            .onAppear { animate = true }
//        }
//    }
//}

import SwiftUI

struct AnimatedCoachBackground: View {

    @State private var animate = false

    private let background = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.03, blue: 0.04),
            Color(red: 0.08, green: 0.08, blue: 0.09),
            Color(red: 0.13, green: 0.02, blue: 0.03),
            .black
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {

        GeometryReader { geo in

            ZStack {

                background
                    .ignoresSafeArea()

                // MARK: - Red Glow

                Circle()
                    .fill(Color.red.opacity(0.25))
                    .frame(width: 350)
                    .blur(radius: 90)
                    .offset(
                        x: animate ? -150 : 120,
                        y: -250
                    )
                    .animation(
                        .easeInOut(duration: 8)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )

                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 250)
                    .blur(radius: 80)
                    .offset(
                        x: animate ? 140 : -80,
                        y: 280
                    )
                    .animation(
                        .easeInOut(duration: 10)
                            .repeatForever(autoreverses: true),
                        value: animate
                    )

                // MARK: - Dumbbell Watermark

                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 170))
                    .foregroundStyle(.white.opacity(0.04))

                // MARK: - Diagonal Metallic Lines

                ForEach(0..<8) { index in

                    Rectangle()
                        .fill(
                            index.isMultiple(of: 2)
                            ? Color.red.opacity(0.12)
                            : Color.white.opacity(0.05)
                        )
                        .frame(width: 2, height: 320)
                        .rotationEffect(.degrees(35))
                        .offset(
                            x: CGFloat(index * 80) - 260,
                            y: -280
                        )
                }

                // MARK: - Hexagon Pattern

                VStack(spacing: 10) {

                    ForEach(0..<5) { row in

                        HStack(spacing: 8) {

                            ForEach(0..<4) { _ in

                                Image(systemName: "hexagon")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.red.opacity(0.12))
                            }
                        }
                    }
                }
                .offset(x: -120, y: -280)

                // MARK: - Floating Ember Particles

                ForEach(0..<35, id: \.self) { index in

                    Circle()
                        .fill(
                            [
                                Color.red,
                                Color.orange,
                                Color.white
                            ][index % 3]
                                .opacity(0.45)
                        )
                        .frame(
                            width: CGFloat.random(in: 2...6),
                            height: CGFloat.random(in: 2...6)
                        )
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .offset(y: animate ? -20 : 20)
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true),
                            value: animate
                        )
                }

                // MARK: - ECG Line

                ECGShape()
                    .trim(from: 0, to: animate ? 1 : 0)
                    .stroke(
                        Color.red,
                        style: StrokeStyle(
                            lineWidth: 2,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: 280, height: 60)
                    .shadow(color: .red.opacity(0.8), radius: 10)
                    .offset(x: -50, y: geo.size.height * 0.34)
                    .animation(
                        .easeInOut(duration: 2)
                            .repeatForever(),
                        value: animate
                    )

                // MARK: - Smoke

                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 240)
                    .blur(radius: 120)
                    .offset(x: -170, y: 340)

                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 200)
                    .blur(radius: 90)
                    .offset(x: 160, y: 330)

                // MARK: - Bottom Chevron

                VStack(spacing: -10) {

                    ForEach(0..<3) { _ in

                        Image(systemName: "chevron.up")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.red.opacity(0.12))
                    }
                }
                .offset(x: 145, y: geo.size.height * 0.37)

                // MARK: - Vignette

                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.75)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - ECG Shape

struct ECGShape: Shape {

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let h = rect.midY

        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: 40, y: h))
        path.addLine(to: CGPoint(x: 60, y: h - 12))
        path.addLine(to: CGPoint(x: 75, y: h + 15))
        path.addLine(to: CGPoint(x: 95, y: h - 32))
        path.addLine(to: CGPoint(x: 120, y: h + 10))
        path.addLine(to: CGPoint(x: 150, y: h))
        path.addLine(to: CGPoint(x: rect.width, y: h))

        return path
    }
}

struct AnimatedCoachBackground_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCoachBackground()
    }
}
