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
    
    enum LoadingState: Equatable {
        case notLoaded
        case loading
        case loaded([Purchase.ID: Purchase])
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
        var purchases: [Purchase.ID: Purchase] = [:]
    }
    
    enum Action: Equatable {
        case loadProducts([Purchase.ID])
        case productsLoaded([Purchase.ID: Purchase])
        case unableToLoad(Error)
        case purchase(Purchase.ID)
        case productPurchased(Purchase.ID)
        case unableToPurchase(Purchase.ID, Error)
        
        static func ==(lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadProducts(let lhsProductIds), .loadProducts(let rhsProductIds)):
                return lhsProductIds == rhsProductIds
            case (.productsLoaded(let lhsPurchases), .productsLoaded(let rhsPurchases)):
                return lhsPurchases == rhsPurchases
            case (.unableToLoad(let lhsError), .unableToLoad(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.purchase(let lhsId), .purchase(let rhsId)):
                return lhsId == rhsId
            case (.productPurchased(let lhsId), .productPurchased(let rhsId)):
                return lhsId == rhsId
            case (.unableToPurchase(let lhsId, let lhsError), .unableToPurchase(let rhsId, let rhsError)):
                return lhsId == rhsId && lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // MARK: Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadProducts(let productIds):
            state.loadingState = .loading
            return .run { send in
                do {
                    let products = try await purchasesProvider.loadPurchasesAvailability(productIds)
                    await send(.productsLoaded(products))
                }
                catch {
                    await send(.unableToLoad(error))
                }
            }
            
        case .productsLoaded(let purchases):
            state.loadingState = .loaded(purchases)
            state.purchases = purchases
            return .none
            
        case .unableToLoad(let error):
            state.loadingState = .error(error)
            return .none
            
        case .purchase(let purchaseID):
            state.purchases[purchaseID]?.purchasingState = .purchasing
            return .run { send in
                do {
                    try await purchasesProvider.purchase(purchaseID)
                    await send(.productPurchased(purchaseID))
                }
                catch {
                    await send(.unableToPurchase(purchaseID, error))
                }
            }
            
        case .productPurchased(let purchaseID):
            state.purchases[purchaseID]?.purchasingState = .purchased
            return .none
            
        case .unableToPurchase(let purchaseID, let error):
            state.purchases[purchaseID]?.purchasingState = .error(error)
            return .none
        }
    }
}