//
// Created by Dmytro Kopanytsia on 01.11.2023.
//

import Foundation
import StoreKit
import ComposableArchitecture

struct PurchasesProvider {
    enum Failure: Error {
        case productNotFound
        case purchaseUnverified(Error)
        case purchaseFailed
        case purchaseCancelled
        case purchasePending
        case unknownPurchaseResult
    }
    var loadPurchasesAvailability: @Sendable ([Purchase.ID]) async throws -> [Purchase.ID: Purchase]
    var purchase: @Sendable (Purchase.ID) async throws -> Void
}

extension PurchasesProvider: DependencyKey {
    static var liveValue: Self {
        let providerActor = Actor()
        return Self(
            loadPurchasesAvailability: {
                try await providerActor.loadPurchasesAvailability($0)
            },
            purchase: {
                try await providerActor.purchase($0)
            }
        )
    }
    
    private actor Actor {
        private var products: [Product.ID: Product] = [:]
        
        func loadPurchasesAvailability(_ productIDs: [Purchase.ID]) async throws -> [Purchase.ID: Purchase] {
            let products = try await Product.products(for: productIDs)
            
            self.products = products.reduce(into: [:]) { result, product in
                result[product.id] = product
            }
            
            let availability = productIDs.reduce(into: [:]) { result, productID in
                if let product = self.products[productID] {
                    result[productID] = Purchase(id: productID, title: product.displayName, description: product.description, price: product.displayPrice, status: .available)
                }
                else {
                    result[productID] = Purchase(id: productID, title: "", description: "", price: "", status: .notAvailable)
                }
            } as [Purchase.ID: Purchase]
            
            return availability
        }
        
        func purchase(_ productId: Product.ID) async throws {
            guard let product = products[productId] else {
                throw Failure.productNotFound
            }
            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                await transaction.finish()
            case let .success(.unverified(_, error)):
                throw Failure.purchaseUnverified(error)
            case .userCancelled:
                throw Failure.purchaseCancelled
            case .pending:
                throw Failure.purchaseFailed // TODO: Process pending state
            @unknown default:
                throw Failure.unknownPurchaseResult
            }
        }
    }
}

extension DependencyValues {
    var purchasesProvider: PurchasesProvider {
        get {
            self[PurchasesProvider.self]
        }
        set {
            self[PurchasesProvider.self] = newValue
        }
    }
}