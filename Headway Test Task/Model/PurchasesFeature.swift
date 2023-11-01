//
//  PurchasesFeature.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import ComposableArchitecture
import StoreKit

struct PurchasesFeature: Reducer {
    // MARK: Dependencies
    
    @Dependency(\.purchasesProvider) var purchasesProvider
    
    // MARK: Types
    
    struct Purchase: Equatable {
        enum PurchasingState: Equatable {
            case notPurchased
            case purchasing
            case purchased
            case error(Error)
            
            static func ==(lhs: PurchasingState, rhs: PurchasingState) -> Bool {
                switch (lhs, rhs) {
                case (.notPurchased, .notPurchased), (.purchasing, .purchasing), (.purchased, .purchased):
                    return true
                case (.error(let lhsError), .error(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                default:
                    return false
                }
            }
        }
        
        var id: Product.ID
        var title: String
        var description: String
        var price: String
        var purchasingState: PurchasingState = .notPurchased
        
    }
    
    enum LoadingState: Equatable {
        case notLoaded
        case loading
        case loaded([Purchase])
        case error(Error)
        
        static func ==(lhs: LoadingState, rhs: LoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded), (.loading, .loading):
                return true
            case (.loaded(let lhsPurchases), .loaded(let rhsPurchases)):
                return lhsPurchases == rhsPurchases
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    struct State: Equatable {
        var loadingState: LoadingState = .notLoaded
        var selectedPurchase: Purchase?
    }
    
    enum Action: Equatable {
        case loadProducts([String])
        case productsLoaded([Product])
        case unableToLoad(Error)
        case selectPurchase(Purchase)
        case deselectPurchase
        case purchase(Purchase)
        case productPurchased(Purchase)
        case unableToPurchase(Error)
        
        static func ==(lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadProducts(let lhsProductIds), .loadProducts(let rhsProductIds)):
                return lhsProductIds == rhsProductIds
            case (.productsLoaded(let lhsPurchases), .productsLoaded(let rhsPurchases)):
                return lhsPurchases == rhsPurchases
            case (.unableToLoad(let lhsError), .unableToLoad(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.selectPurchase(let lhsPurchase), .selectPurchase(let rhsPurchase)):
                return lhsPurchase == rhsPurchase
            case (.deselectPurchase, .deselectPurchase):
                return true
            case (.purchase(let lhsPurchase), .purchase(let rhsPurchase)):
                return lhsPurchase == rhsPurchase
            case (.productPurchased(let lhsPurchases), .productPurchased(let rhsPurchases)):
                return lhsPurchases == rhsPurchases
            case (.unableToPurchase(let lhsError), .unableToPurchase(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadProducts(let productIds):
            state.loadingState = .loading
            return .run { send in
                do {
                    let products = try await purchasesProvider.loadProducts(productIds)
                    await send(.productsLoaded(products))
                }
                catch {
                    await send(.unableToLoad(error))
                }
            }
            
        case .productsLoaded(let products):
            let purchases = products.map { product in
                Purchase(id: product.id, title: product.displayName, description: product.description, price: product.displayPrice)
            }
            state.loadingState = .loaded(purchases)
            return .none
            
        case .unableToLoad(let error):
            state.loadingState = .error(error)
            return .none
            
        case .selectPurchase(let purchase):
            state.selectedPurchase = purchase
            return .none
            
        case .deselectPurchase:
            state.selectedPurchase = nil
            return .none
            
        case .purchase(let purchase):
            state.selectedPurchase?.purchasingState = .purchasing
            return .run { send in
                do {
                    try await purchasesProvider.purchase(purchase.id)
                    await send(.productPurchased(purchase))
                }
                catch {
                    await send(.unableToPurchase(error))
                }
            }
            
        case .productPurchased(let purchase):
            state.selectedPurchase?.purchasingState = .purchased
            return .none
            
        case .unableToPurchase(let error):
            state.selectedPurchase?.purchasingState = .error(error)
            return .none
        }
    }
}