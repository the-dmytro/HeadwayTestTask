//
// Created by Dmytro Kopanytsia on 04.11.2023.
//

import SwiftUI

struct PlayerButtonStyle: ViewModifier {
    enum PlayerButtonStyleType: CGFloat {
        case small = 23
        case medium = 28
        case large = 36
    }
    
    let type: PlayerButtonStyleType
    
    init(_ type: PlayerButtonStyleType = .medium) {
        self.type = type
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: type.rawValue))
            .foregroundColor(.invertibleBlack)
    }
}

extension Image {
    func playerButtonStyle(_ type: PlayerButtonStyle.PlayerButtonStyleType) -> some View {
        self.modifier(PlayerButtonStyle(type))
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .circular)
                .fill(Color.invertibleWhite)
                .frame(width: 110, height: 60)
                .overlay(
                    Circle()
                        .fill(Color.appBlue)
                        .padding(3)
                        .offset(x: configuration.isOn ? 25 : -25)
                )
                .addBorder(Color.appGray, width: 0.5, cornerRadius: 30)
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
            HStack(spacing: 20) {
                Image(systemName: "headphones")
                    .foregroundColor(configuration.isOn ? .invertibleBlack : .white)
                    .font(.system(size: 24))
                Image(systemName: "list.bullet")
                    .foregroundColor(configuration.isOn ? .white : .invertibleBlack)
                    .font(.system(size: 24))
            }
        }
    }
}
