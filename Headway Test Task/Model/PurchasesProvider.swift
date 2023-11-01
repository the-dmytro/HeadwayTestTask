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
    var loadProducts: @Sendable ([Product.ID]) async throws -> [Product.ID: Product]
    var purchase: @Sendable (Product.ID) async throws -> Void
}

extension PurchasesProvider: DependencyKey {
    static var liveValue: Self {
        let providerActor = Actor()
        return Self(
            loadProducts: {
                try await providerActor.loadProducts($0)
            },
            purchase: {
                try await providerActor.purchase($0)
            }
        )
    }
    
    private actor Actor {
        private var products: [Product.ID: Product] = [:]
        
        func loadProducts(_ productIDs: [Product.ID]) async throws -> [Product.ID: Product] {
            let products = try await Product.products(for: productIDs)
            self.products = products.reduce(into: [:]) { result, product in
                result[product.id] = product
            }
            return self.products
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