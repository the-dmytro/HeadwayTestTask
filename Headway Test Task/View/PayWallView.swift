//
// Created by Dmytro Kopanytsia on 03.11.2023.
//

import SwiftUI

struct PayWallView: View {
    @ObservedObject var viewModel: PayWallViewModel
    
    var body: some View {
        if viewModel.isPresented {
            VStack(spacing: 0) {
                transparentView
                gradientView
                purchaseView
            }
        }
        else {
            EmptyView()
        }
    }
    
    private var transparentView: some View {
        Color.clear
            .frame(height: 300)
    }
    
    private var gradientView: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.appBackgroudColor.opacity(0.0), Color.appBackgroudColor]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var purchaseView: some View {
        VStack(spacing: 24) {
            if viewModel.isLoading {
                loadingView
            } else {
                title
                subtitle
                purchaseButtonView
            }
        }
            .frame(height: 240)
            .background(Color.appBackgroudColor)
    }
    
    private var title: some View {
        Text("Unlock learning")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.invertibleBlack)
            .padding(.top, 20)
    }
    
    private var subtitle: some View {
        Text("Grow on the go by listening and reading\nthe world's best ideas")
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.invertibleBlack)
            .multilineTextAlignment(.center)
            .padding(.top, 10)
    }
    
    private var purchaseButtonView: some View {
        ZStack {
            Color.appGray
                .frame(height: 50)
                .padding(.horizontal, 16)
            Group {
                if viewModel.isProcessingPurchase {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    BigBlueButton(title: viewModel.purchaseButtonText,
                                  isEnabled: true) {
                        viewModel.purchaseAction()
                    }
                }
            }
        }
            .mask(
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .padding(.horizontal, 16)
            )
            .animation(.easeInOut, value: viewModel.isProcessingPurchase)
    }
    
    private var loadingView: some View {
        LoadingView()
    }
}