//
// Created by Dmytro Kopanytsia on 04.11.2023.
//

import SwiftUI

struct BigBlueButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            ZStack {
                Rectangle()
                    .foregroundColor(isEnabled ? Color.appBlue : Color.appGray)
                Text(title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.invertibleWhite)
                    .lineLimit(1)
            }
        })
            .disabled(isEnabled == false)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.clear
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2)
        }
    }
}