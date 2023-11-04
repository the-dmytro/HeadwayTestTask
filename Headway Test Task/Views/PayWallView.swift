//
// Created by Dmytro Kopanytsia on 03.11.2023.
//

import SwiftUI

struct PayWallView: View {
    @StateObject var viewModel: PayWallViewModel
    
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
        ZStack {
            Color.appBackgroudColor
                .frame(height: 240)
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    loadingView
                } else {
                    if let generalErrorText = viewModel.generalErrorText {
                        errorView(text: generalErrorText)
                    } else {
                        title
                        subtitle
                        purchaseButtonView
                    }
                }
            }
        }
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
                .padding(.horizontal, 16)
            Group {
                if viewModel.isProcessingPurchase {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    if let purchaseErrorText = viewModel.purchaseErrorText {
                        BigBlueButton(title: purchaseErrorText,
                            isEnabled: false) {
                            viewModel.purchaseAction()
                        }
                    }
                    else {
                        BigBlueButton(title: viewModel.purchaseButtonText,
                            isEnabled: viewModel.isAvailable) {
                            viewModel.purchaseAction()
                        }
                    }
                }
            }
        }
            .frame(height: 50)
            .mask(
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 50)
                    .padding(.horizontal, 16)
            )
    }
    
    private var loadingView: some View {
        LoadingView()
    }
    
    private func errorView(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.invertibleBlack)
            .multilineTextAlignment(.center)
            .padding(.top, 10)
    }
}