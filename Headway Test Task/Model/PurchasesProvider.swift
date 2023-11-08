//
// Created by Dmytro Kopanytsia on 01.11.2023.
//

import Foundation
import StoreKit
import ComposableArchitecture

struct PurchasesProvider {
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
                throw PurchaseFailure.productNotFound
            }
            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                await transaction.finish()
            case let .success(.unverified(_, error)):
                throw PurchaseFailure.purchaseUnverified(error)
            case .userCancelled:
                throw PurchaseFailure.purchaseCancelled
            case .pending:
                throw PurchaseFailure.purchaseFailed // TODO: Process pending state
            @unknown default:
                throw PurchaseFailure.unknownPurchaseResult
            }
        }
    }
    
    private actor FakeActor {
        func loadPurchasesAvailability(_ productIDs: [Purchase.ID]) async throws -> [Purchase.ID: Purchase] {
            try await Task.wait(seconds: Double.random(in: 0.5...1.5))
            if Bool.random() {
                throw PurchaseFailure.productNotFound
            }
            return productIDs.reduce(into: [:]) { result, productID in
                result[productID] = Purchase(id: productID, title: "Атомні звички", description: "Стислий переказ бестселлера Джеймса Кліра, згенерований ChatGPT, озвучений синтезатором голосу Lesya на macOS", price: "250 UAH", status: .available)
            } as [Purchase.ID: Purchase]
        }
        
        func purchase(_ productId: Product.ID) async throws {
            try await Task.wait(seconds: Double.random(in: 0.5...1.5))
            if Bool.random() {
                throw Bool.random() ? PurchaseFailure.purchaseFailed : PurchaseFailure.purchaseCancelled
            }
        }
        
        func wait(seconds: Double) async throws {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
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

extension Task where Success == Never, Failure == Never {
    static func wait(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}