//
// Created by Dmytro Kopanytsia on 03.11.2023.
//

import SwiftUI

struct PayWallView: View {
    @ObservedObject var viewModel: PayWallViewModel
    
    var body: some View {
        VStack {
            transparentView
            gradientView
            purchaseView
        }
    }
    
    private var transparentView: some View {
        Color.clear
    }
    
    private var gradientView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.0)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var purchaseView: some View {
        VStack {
            Text("Unlock learning")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 20)
            
            Text("Grow on the go by listening and reading\nthe world's best ideas")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
    }
}
